import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/auth_session.dart';
import 'package:my_auto/core/auth/auth_token_store.dart';
import 'package:my_auto/core/auth/refresh_single_flight.dart';
import 'package:my_auto/core/model/user/index.dart';
import 'package:my_auto/core/network/websocket_recovery_service.dart';
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/core/services/graphql/optional_auth_operations.dart';
import 'package:my_auto/core/services/graphql/public_auth_operations.dart';
import 'package:my_auto/features/auth/data/api/auth_api.dart';

/// Single source of truth for auth lifecycle, refresh, and request barriers.
class AuthCoordinator extends ChangeNotifier {
  AuthCoordinator._();
  static final AuthCoordinator instance = AuthCoordinator._();

  static Future<void> Function()? onRefreshFailed;

  final RefreshSingleFlight _refreshFlight = RefreshSingleFlight();

  AuthLifecycle _lifecycle = AuthLifecycle.unknown;
  AuthSession? _session;
  Completer<void>? _bootstrapCompleter;

  AuthLifecycle get lifecycle => _lifecycle;
  AuthSession? get session => _session;
  bool get isAuthenticated =>
      _lifecycle == AuthLifecycle.authenticated && _session != null;
  bool get isRefreshing =>
      _lifecycle == AuthLifecycle.refreshing || _refreshFlight.isRunning;

  String? get accessToken =>
      AuthTokenStore.memoryAccess ?? _session?.accessToken;

  Future<void> guardRequest(Request request) async {
    if (isPublicAuthOperation(request)) return;
    if (isOptionalAuthOperation(request)) return;
    await whenReady();
    if (accessToken == null || accessToken!.isEmpty) {
      throw StateError('AUTH_REQUIRED: no access token');
    }
  }

  Future<void> whenReady() async {
    if (_lifecycle == AuthLifecycle.bootstrapping &&
        _bootstrapCompleter != null) {
      await _bootstrapCompleter!.future;
    }
    await _refreshFlight.whenIdle();
  }

  Future<bool> bootstrap() async {
    if (_lifecycle == AuthLifecycle.bootstrapping &&
        _bootstrapCompleter != null) {
      await _bootstrapCompleter!.future;
      return isAuthenticated;
    }

    _lifecycle = AuthLifecycle.bootstrapping;
    _bootstrapCompleter = Completer<void>();
    notifyListeners();

    try {
      final restored = await AuthTokenStore.readSession();
      if (restored == null) {
        await AuthTokenStore.clearOrphanBearer();
        _session = null;
        _lifecycle = AuthLifecycle.unauthenticated;
        GraphQLLinks.setMemoryAccessToken(null);
        return false;
      }

      _session = restored;
      GraphQLLinks.setMemoryAccessToken(restored.accessToken);
      _lifecycle = AuthLifecycle.authenticated;
      return true;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AuthCoordinator] bootstrap failed: $e\n$st');
      await clearSession(notify: false);
      return false;
    } finally {
      _bootstrapCompleter?.complete();
      _bootstrapCompleter = null;
      notifyListeners();
    }
  }

  Future<void> establishSession(AuthSession session) async {
    _session = session;
    await AuthTokenStore.persistSession(session);
    GraphQLLinks.setMemoryAccessToken(session.accessToken);
    _lifecycle = AuthLifecycle.authenticated;
    notifyListeners();
    await GraphQLLinks.refreshWebSocketAuth(
      recoveryReason: 'session_established',
    );
  }

  Future<void> establishFromAuthOutput(AuthOutput output) =>
      establishSession(AuthSession.fromAuthOutput(output));

  Future<void> updateUser(User user) async {
    if (_session == null) return;
    _session = _session!.copyWith(user: user);
    await AuthTokenStore.persistSession(_session!);
    notifyListeners();
  }

  /// Single-flight refresh — safe under parallel TOKEN_EXPIRED responses.
  Future<bool> refreshSession({bool force = false}) {
    return _refreshFlight.run(() => _performRefresh(force: force));
  }

  Future<bool> _performRefresh({required bool force}) async {
    final refresh = await AuthTokenStore.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      if (force) await clearSession();
      return false;
    }

    final priorLifecycle = _lifecycle;
    _lifecycle = AuthLifecycle.refreshing;
    notifyListeners();

    try {
      final deviceId = await AuthTokenStore.deviceId();
      final client = GraphQLClient(
        cache: GraphQLCache(),
        link: GraphQLLinks.httpLink,
      );

      final result = await client.mutate(
        MutationOptions(
          document: gql(refreshSessionMutation),
          operationName: 'RefreshSession',
          variables: {
            'refreshToken': refresh,
            'deviceId': deviceId,
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        final code = result.exception?.graphqlErrors.firstOrNull?.extensions?['code']
            ?.toString()
            .toUpperCase();
        if (shouldRevokeForRefreshError(code: code) ||
            code == 'TOKEN_EXPIRED') {
          await clearSession();
        }
        return false;
      }

      final payload = result.data?['refreshSession'];
      if (payload == null) return false;

      final next =
          AuthSession.fromJson(Map<String, dynamic>.from(payload as Map));
      if (next.accessToken.isEmpty) return false;

      _session = (_session != null && next.user.id.isEmpty)
          ? next.copyWith(user: _session!.user)
          : next;
      await AuthTokenStore.persistSession(_session!);
      GraphQLLinks.setMemoryAccessToken(_session!.accessToken);
      _lifecycle = AuthLifecycle.authenticated;

      await GraphQLLinks.refreshWebSocketAuth(
        recoveryReason: 'token_refresh',
      );
      WebSocketRecoveryService.instance.scheduleRecovery(
        reason: 'token_refresh',
      );
      notifyListeners();
      return true;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AuthCoordinator] refresh failed: $e\n$st');
      return false;
    } finally {
      if (_lifecycle == AuthLifecycle.refreshing) {
        _lifecycle = _session != null
            ? AuthLifecycle.authenticated
            : priorLifecycle == AuthLifecycle.bootstrapping
                ? AuthLifecycle.unauthenticated
                : AuthLifecycle.unauthenticated;
      }
      notifyListeners();
    }
  }

  bool shouldRefreshForGraphQLError({String? code, String? message}) {
    final c = (code ?? '').toUpperCase();
    if (c == 'TOKEN_EXPIRED' || c == 'AUTH_TOKEN_EXPIRED') return true;
    final m = (message ?? '').toLowerCase();
    return m.contains('token expired') || m.contains('jwt expired');
  }

  bool shouldRevokeForRefreshError({String? code}) {
    final c = (code ?? '').toUpperCase();
    return c == 'INVALID_REFRESH_TOKEN' || c == 'SESSION_REVOKED';
  }

  Future<void> clearSession({bool notify = true}) async {
    _refreshFlight.reset();
    _session = null;
    _lifecycle = AuthLifecycle.unauthenticated;
    GraphQLLinks.setMemoryAccessToken(null);
    await AuthTokenStore.clear();
    await GraphQLLinks.disconnectWebSocket();
    if (notify) notifyListeners();
  }

  Future<void> logoutCurrentDevice() async {
    final refresh = await AuthTokenStore.readRefreshToken();
    final sessionId = await AuthTokenStore.readSessionId();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        final client = GraphQLClient(
          cache: GraphQLCache(),
          link: GraphQLLinks.httpLink,
        );
        await client.mutate(
          MutationOptions(
            document: gql(logoutSessionMutation),
            operationName: 'LogoutSession',
            variables: {
              if (sessionId != null) 'sessionId': sessionId,
              'refreshToken': refresh,
            },
          ),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[AuthCoordinator] logout mutation: $e');
      }
    }
    await clearSession();
  }

  Future<void> logoutAllDevices() async {
    final access = accessToken;
    if (access != null && access.isNotEmpty) {
      try {
        GraphQLLinks.setMemoryAccessToken(access);
        final client = GraphQLClient(
          cache: GraphQLCache(),
          link: GraphQLLinks.link,
        );
        await client.mutate(
          MutationOptions(
            document: gql(logoutAllDevicesMutation),
            operationName: 'LogoutAllDevices',
          ),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[AuthCoordinator] logoutAll: $e');
      }
    }
    await clearSession();
  }
}
