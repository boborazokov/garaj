import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/features/notifications/presentation/notification_l10n.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart' show navigatorKey;

import '../data/repositories/device_token_repository.dart';
import '../notifications_constants.dart';
import 'push_router.dart';

/// Owns the full lifecycle of the push subsystem on the device:
///  1. requests notification permission (Android 13+ / iOS),
///  2. ensures the notification channel exists,
///  3. retrieves and persists the FCM registration token to the server,
///  4. listens to foreground / background / terminated message taps,
///  5. surfaces foreground messages via flutter_local_notifications
///     (FCM does NOT auto-display them while the app is in foreground).
///
/// The class is intentionally a SINGLETON-friendly plain Dart object —
/// instantiate it once at app start, call [bootstrap], and forward any
/// auth-state transitions via [refreshTokenForUser] / [removeTokenOnLogout].
///
/// It exposes no public mutable state. Anything the UI needs (unread
/// badge counters, last received notification, etc.) flows through the
/// `NotificationsBloc`.
class PushService {
  PushService({
    required this.deviceTokens,
    required this.router,
  });

  final DeviceTokenRepository deviceTokens;
  final PushRouter router;

  static const _secureStorage = FlutterSecureStorage();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _bootstrapped = false;
  bool _tokenRegistrationInFlight = false;
  String? _lastRegisteredToken;
  bool _channelLocalized = false;

  /// False on emulators without Google Play Services or when FCM init fails.
  bool operational = false;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  /// Tracks whether the user is authenticated; supplied as a callback
  /// so the service can decide whether to upload the token now or
  /// queue the registration for after login.
  final ValueNotifier<bool> _isAuthed = ValueNotifier<bool>(false);

  /// Pending token to register the moment the user signs in.
  String? _pendingToken;

  /// Call once at app start. Idempotent.
  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    await _configureLocal();
    await _requestPermission();
    await _ensureForegroundPresentationOnIOS();

    final tokenProbe = await _safeGetToken();
    operational = tokenProbe != null;

    // Initial token: may be null on iOS until APNs is ready; we'll
    // also handle the `onTokenRefresh` event below as a backstop.
    await _captureCurrentToken();
    if (_lastRegisteredToken != null || tokenProbe != null) {
      operational = true;
    }
    if (_isAuthed.value) {
      await _registerTokenWhenAuthed(force: true);
    }

    _onTokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      _lastRegisteredToken = null; // force re-register after refresh
      unawaited(_registerTokenWithBackend(token));
    });

    _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    // Cold-start case: app was terminated and the user tapped a push.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _onTap(initial);
  }

  /// Notifies the service that the user authenticated. Replays any
  /// pending token registration that was deferred until login.
  Future<void> onSignedIn() async {
    _isAuthed.value = true;
    _lastRegisteredToken = null;

    await _registerTokenWhenAuthed(force: true);

    // FCM can return null on first frame after install — retry once.
    if (_lastRegisteredToken == null) {
      await Future<void>.delayed(const Duration(seconds: 2));
      await _registerTokenWhenAuthed(force: true);
    }

    router.consumePendingDeepLink();
  }

  /// Notifies the service that the user signed out. We deactivate the
  /// token server-side and stop the local cache.
  Future<void> onSignedOut() async {
    _isAuthed.value = false;
    final token = _lastRegisteredToken ?? await _safeGetToken();
    _lastRegisteredToken = null;
    _pendingToken = null;
    if (token == null) return;

    final jwt = await _secureStorage.read(key: 'authToken');
    if (jwt == null || jwt.isEmpty) {
      return;
    }

    try {
      await deviceTokens.remove(token);
    } catch (e) {
      if (_isBenignRemoveTokenError(e)) return;
      _log('remove token failed: $e');
    }
  }

  bool _isBenignRemoveTokenError(Object e) {
    if (e is! OperationException) return false;
    final errors = e.graphqlErrors;
    if (errors.isEmpty) return false;
    final code = errors.first.extensions?['code']?.toString();
    return code == 'UNAUTHENTICATED' ||
        errors.first.message.toLowerCase().contains('unauthorized');
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
  }

  // ------------------- internals -------------------

  Future<void> _configureLocal() async {
    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final initLinux = LinuxInitializationSettings(
      defaultActionName: resolveNotificationStrings(navigatorKey.currentContext)
          .notificationOpenAction,
    );
    final init = InitializationSettings(
      android: initAndroid,
      iOS: initIOS,
      linux: initLinux,
    );

    await _local.initialize(
      settings: init,
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          router.route(data);
        } catch (_) {
          /* malformed payload — drop */
        }
      },
    );

    await _ensureLocalizedChannel(resolveNotificationStrings(
      navigatorKey.currentContext,
    ));
  }

  Future<void> _ensureLocalizedChannel(S s) async {
    if (_channelLocalized) return;
    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        PushChannels.highId,
        s.pushChannelName,
        description: s.pushChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    _channelLocalized = true;
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _log('permission=${settings.authorizationStatus}');
    } catch (e) {
      _log('requestPermission failed: $e');
    }
  }

  Future<void> _ensureForegroundPresentationOnIOS() async {
    if (!kIsWeb && Platform.isIOS) {
      // On iOS, FCM by default suppresses notifications while the app
      // is in foreground. We re-enable the banner so chat pings are
      // never missed.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _captureCurrentToken() async {
    final token = await _safeGetToken();
    if (token == null) return;
    if (!_isAuthed.value) {
      _pendingToken = token;
      return;
    }
    await _registerTokenWithBackend(token);
  }

  Future<void> _registerTokenWhenAuthed({bool force = false}) async {
    final bearer = await GraphQLLinks.readBearer();
    if (bearer == null) {
      _log('registerDeviceToken skipped — no Bearer');
      return;
    }

    if (force) _lastRegisteredToken = null;

    final token = _pendingToken ?? await _safeGetToken();
    if (token == null) {
      _log('registerDeviceToken skipped — no FCM token yet');
      return;
    }
    _pendingToken = null;
    await _registerTokenWithBackend(token);
  }

  Future<String?> _safeGetToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      _log('getToken failed: $e');
      return null;
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    if (_tokenRegistrationInFlight) return;
    if (_lastRegisteredToken == token) return;

    _tokenRegistrationInFlight = true;
    try {
      await deviceTokens.register(
        token: token,
        platform: DeviceTokenRepository.detectPlatform(),
      );
      _lastRegisteredToken = token;
      final preview =
          token.length > 12 ? '${token.substring(0, 12)}…' : token;
      _log('registerDeviceToken ok ($preview)');
    } catch (e) {
      // Don't crash on network / auth failure. The next refresh /
      // sign-in attempt will retry. Crucially, we DO NOT mark the
      // token as registered so a subsequent attempt is allowed.
      _log('registerDeviceToken failed: $e');
    } finally {
      _tokenRegistrationInFlight = false;
    }
  }

  Map<String, dynamic> _enrichedPushData(RemoteMessage message) {
    final out = <String, dynamic>{
      for (final e in message.data.entries)
        if (e.value != null) e.key: e.value.toString(),
    };

    final type = out[PushDataKeys.type]?.toString();
    final conversationId = out[PushDataKeys.conversationId]?.toString();
    final orderId = out[PushDataKeys.orderId]?.toString();
    final deepLink = out[PushDataKeys.deepLink]?.toString();

    if (deepLink == null || deepLink.isEmpty) {
      if (type == PushEventTypes.chat &&
          conversationId != null &&
          conversationId.isNotEmpty) {
        out[PushDataKeys.deepLink] = '${RoutesName.chatDetail}/$conversationId';
      } else if (type == PushEventTypes.orderReply &&
          orderId != null &&
          orderId.isNotEmpty) {
        out[PushDataKeys.deepLink] = '${RoutesName.orderDetail}/$orderId';
      }
    }

    return out;
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final data = _enrichedPushData(message);
    final s = resolveNotificationStrings(navigatorKey.currentContext);
    await _ensureLocalizedChannel(s);

    final localized = localizeRemoteMessage(s, message);

    var title = localized.title;
    var body = localized.body;

    if (title.isEmpty && body.isEmpty) {
      if (data[PushDataKeys.type]?.toString() == PushEventTypes.chat) {
        title = s.notificationNewMessageTitle;
        body = s.notificationNewMessageBody;
      } else {
        return;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      PushChannels.highId,
      s.pushChannelName,
      channelDescription: s.pushChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final iosDetails = DarwinNotificationDetails(
      threadIdentifier: data[PushDataKeys.conversationId]?.toString(),
    );

    await _local.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode(data),
    );
  }

  void _onTap(RemoteMessage message) {
    router.route(_enrichedPushData(message));
  }

  void _log(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[PushService] $msg');
    }
  }
}
