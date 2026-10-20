import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/auth_coordinator.dart';
import 'package:my_auto/core/auth/auth_refresh_link.dart';
import 'package:my_auto/core/auth/auth_token_store.dart';
import 'package:my_auto/core/network/websocket_recovery_service.dart';

import 'optional_auth_operations.dart';
import 'public_auth_operations.dart';

/// Builds the composed GraphQL link stack (auth → errors → transport).
class GraphQLLinks {
  GraphQLLinks._();

  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'authToken';

  /// In-memory JWT so the first authenticated request after login does not
  /// race secure-storage I/O (registerDeviceToken, subscriptions, etc.).
  static String? _memoryAccessToken;

  static void setMemoryAccessToken(String? token) {
    _memoryAccessToken =
        (token != null && token.isNotEmpty) ? token : null;
  }

  static late HttpLink httpLink;
  static late WebSocketLink wsLink;
  static late Link link;
  static ErrorLink? _errorLink;

  static void initialize() {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    httpLink = HttpLink(
      '$apiUrl/api',
      defaultHeaders: {
        if (apiUrl.contains('ngrok')) 'ngrok-skip-browser-warning': 'true',
      },
    );
    _createWebSocketLink();
    _rebuildStack();
  }

  static void _createWebSocketLink() {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final wsBase = apiUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');

    wsLink = WebSocketLink(
      '$wsBase/api',
      config: SocketClientConfig(
        autoReconnect: true,
        delayBetweenReconnectionAttempts: const Duration(seconds: 4),
        inactivityTimeout: const Duration(seconds: 30),
        initialPayload: _wsAuthPayload,
      ),
    );
  }

  static Future<void> refreshWebSocketAuth({
    String recoveryReason = 'ws_reconnect',
  }) async {
    final token = _memoryAccessToken ??
        AuthTokenStore.memoryAccess ??
        await _secureStorage.read(key: _tokenKey);
    try {
      await wsLink.dispose();
    } catch (_) {
      /* already closed */
    }

    _createWebSocketLink();
    if (_errorLink != null) {
      _rebuildStack();
    }

    if (token == null || token.isEmpty) return;

    wsLink.connectOrReconnect();
    WebSocketRecoveryService.instance.scheduleRecovery(reason: recoveryReason);
  }

  /// Disconnect WS when logged out — prevents anonymous subscription leaks.
  static Future<void> disconnectWebSocket() async {
    try {
      await wsLink.dispose();
    } catch (_) {}
    _createWebSocketLink();
    if (_errorLink != null) _rebuildStack();
  }

  static Future<Map<String, String>> _wsAuthPayload() async {
    final token = _memoryAccessToken ??
        AuthTokenStore.memoryAccess ??
        await _secureStorage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return const {};
    }
    return {'authorization': 'Bearer $token'};
  }

  static Link _sessionAuthLink() => _SessionAuthLink();

  static Future<String?> readBearer() async {
    final token = _memoryAccessToken ??
        AuthTokenStore.memoryAccess ??
        await _secureStorage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;
    return 'Bearer $token';
  }

  static void _rebuildStack() {
    final httpTail = _errorLink != null
        ? AuthRefreshLink()
            .concat(_sessionAuthLink())
            .concat(_errorLink!)
            .concat(httpLink)
        : AuthRefreshLink()
            .concat(_sessionAuthLink())
            .concat(httpLink);

    link = Link.split(
      (request) => request.isSubscription,
      WebSocketAuthGateLink().concat(wsLink),
      httpTail,
    );
  }

  static void applyErrorLink(ErrorLink errorLink) {
    _errorLink = errorLink;
    _rebuildStack();
  }
}

class _SessionAuthLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final next = forward;
    if (next == null) return;

    if (isPublicAuthOperation(request)) {
      yield* next(request);
      return;
    }

    if (isOptionalAuthOperation(request)) {
      yield* AuthLink(getToken: GraphQLLinks.readBearer).request(request, next);
      return;
    }

    try {
      await AuthCoordinator.instance.guardRequest(request);
    } catch (_) {
      yield* Stream.error(
        OperationException(
          graphqlErrors: [
            GraphQLError(
              message: 'Authentication required',
              extensions: const {'code': 'UNAUTHENTICATED'},
            ),
          ],
        ),
      );
      return;
    }

    yield* AuthLink(getToken: GraphQLLinks.readBearer).request(request, next);
  }
}
