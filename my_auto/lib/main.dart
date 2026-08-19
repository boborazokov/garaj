import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:my_auto/core/app/index.dart';
import 'package:my_auto/core/firebase/firebase_options_stub.dart';
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/core/auth/auth_coordinator.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/routes/app_router.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/provider/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:my_auto/core/provider/home/setFavorite/favorites_auth_listener.dart';
import 'package:my_auto/features/notifications/notifications.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Globally accessible push surface. Exposed as a top-level so that
/// the existing Provider-based auth flow can call
/// `pushService.onSignedIn()` / `pushService.onSignedOut()` without
/// pulling a BuildContext.
///
/// The Bloc version (`NotificationsBloc`) sits on top of the same
/// service and is what UI code should consume; the bare service
/// reference exists for the auth callbacks that fire from outside the
/// widget tree (e.g. token refresh in `AuthProvider`).
late final PushService pushService;
late final PushRouter pushRouter;

/// Optional chat probe after cold start — must not wipe a valid saved session.
Future<void> _warmRestoredSession(AuthProvider auth) async {
  if (auth.auth == null) return;

  GraphQLConfig.suppressSessionExpiryHandler = true;
  try {
    await chatRepository.getConversations(limit: 1);
  } catch (e, st) {
    debugPrint(
      '[main] session warm probe failed (keeping saved session): $e\n$st',
    );
  } finally {
    GraphQLConfig.suppressSessionExpiryHandler = false;
  }

  await AuthProvider.onSignedInHook?.call();
}

/// Log out and open sign-in when the session is invalid (401 / UNAUTHENTICATED).
Future<void> handleAuthLost(AuthProvider auth) async {
  await auth.revokeSession();
  PendingActionManager.instance.clear();

  final ctx = navigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;

  final router = GoRouter.of(ctx);
  final loc = router.state.matchedLocation;
  if (loc != RoutesName.signin && loc != RoutesName.signup) {
    router.go(RoutesName.signin);
    Toaster.error(S.of(ctx).sessionExpired);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------- 1. Environment --------------------
  await dotenv.load(fileName: ".env");

  // -------------------- 2. Firebase + Push background --------------------
  // Firebase MUST be initialized before any FCM API is touched, both on
  // the main isolate AND inside the background handler isolate (the
  // handler does it itself). Initialization is cheap; if creds are
  // missing we still let the rest of the app boot.
  try {
    await AppFirebase.initialize();
  } catch (e) {
    debugPrint('[main] Firebase init failed (push will be disabled): $e');
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // -------------------- 3. Auth + Locale (existing) --------------------
  final authProvider = AuthProvider();
  await authProvider.loadAuth();

  // -------------------- 4. GraphQL + Chat --------------------
  GraphQLConfig.initialize();
  GraphQLConfig.onSessionExpired = () => handleAuthLost(authProvider);
  AuthCoordinator.onRefreshFailed = () => handleAuthLost(authProvider);
  initializeChatRepository();
  initializeOrdersRepository();
  initializeServicesRepository();

  // -------------------- 5. Push subsystem --------------------
  pushRouter = PushRouter(
    navigatorKey: navigatorKey,
    isAuthenticated: () => authProvider.auth != null,
  );
  pushService = PushService(
    deviceTokens: DeviceTokenRepository(GraphQLConfig.client()),
    router: pushRouter,
  );

  // FCM listeners must exist before we register the device token.
  await pushService.bootstrap();

  AuthProvider.onSignedInHook = () async {
    await pushService.onSignedIn();
  };
  AuthProvider.onSignedOutHook = () async {
    await clearChatSessionData();
    await pushService.onSignedOut();
  };

  if (authProvider.auth != null) {
    await GraphQLLinks.refreshWebSocketAuth();
    await _warmRestoredSession(authProvider);
  }

  appRouter = createAppRouter(authProvider);

  // -------------------- 6. App --------------------
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ...providers,
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NotificationsBloc>(
            create: (_) => NotificationsBloc(pushService: pushService)
              ..add(const NotificationsBootstrapped()),
          ),
        ],
        child: const FavoritesAuthListener(child: MyApp()),
      ),
    ),
  );
}
