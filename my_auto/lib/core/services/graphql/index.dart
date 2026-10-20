import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:provider/provider.dart';
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/core/services/graphql/public_auth_operations.dart';
import 'package:my_auto/main.dart';

late String fileUrl;
late String apiUrl;

class GraphQLConfig {
  static final _secureStorage = FlutterSecureStorage();

  /// Clears session and navigates to sign-in (set from [main]).
  static Future<void> Function()? onSessionExpired;

  /// While true, 401 responses are forwarded without revoke (session probe).
  static bool suppressSessionExpiryHandler = false;

  static bool _revokeInFlight = false;
  static DateTime? _lastRevokeAt;

  static void initialize() {
    apiUrl = dotenv.env['API_URL'] ?? "";
    fileUrl = dotenv.env['API_File_URL'] ?? "";
    GraphQLLinks.initialize();
    GraphQLLinks.applyErrorLink(_errorLink);
  }

  /// Global link: log + session revoke only. No generic server toasts.
  static ErrorLink get _errorLink => ErrorLink(
        onException: (request, forward, exception) {
          _logSilenced(request, exception);
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted && exception is ServerException) {
            _maybeHandleUnauthorizedFromServer(ctx, request, exception);
          }
          return forward(request);
        },
        onGraphQLError: (request, forward, response) {
          _logSilenced(request, response.errors?.firstOrNull?.message);
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            _maybeHandleUnauthorizedFromGraphql(ctx, request, response);
          }
          return forward(request);
        },
      );

  static void _logSilenced(Request request, Object? detail) {
    if (!kDebugMode) return;
    final name = request.operation.operationName ?? 'anonymous';
    debugPrint('[GraphQL] $name (no global toast): $detail');
  }

  static void _maybeHandleUnauthorizedFromServer(
    BuildContext ctx,
    Request request,
    ServerException exception,
  ) {
    final code = exception
        .parsedResponse?.errors?.firstOrNull?.extensions?['code']
        ?.toString();
    final message =
        exception.parsedResponse?.errors?.firstOrNull?.message ?? '';
    if (_shouldRevokeSession(
      request: request,
      code: code,
      message: message,
      statusCode: exception.statusCode,
    )) {
      _handleUnauthorized(ctx);
    }
  }

  static void _maybeHandleUnauthorizedFromGraphql(
    BuildContext ctx,
    Request request,
    Response response,
  ) {
    final err = response.errors?.firstOrNull;
    if (err == null) return;
    if (_shouldRevokeSession(
      request: request,
      code: err.extensions?['code']?.toString(),
      message: err.message,
    )) {
      _handleUnauthorized(ctx);
    }
  }

  static GraphQLClient client() =>
      GraphQLClient(cache: GraphQLCache(), link: GraphQLLinks.link);

  static ValueNotifier<GraphQLClient> graphqlClient() =>
      ValueNotifier(client());

  static Future<void> saveToken(String token) async {
    GraphQLLinks.setMemoryAccessToken(token);
    await _secureStorage.write(key: "authToken", value: token);
    await GraphQLLinks.refreshWebSocketAuth();
  }

  static bool _shouldRevokeSession({
    required Request request,
    String? code,
    String? message,
    int? statusCode,
  }) {
    if (suppressSessionExpiryHandler) return false;
    if (isPublicAuthOperation(request) || _isPushTokenLifecycleOp(request)) {
      return false;
    }

    final normalizedCode = code?.toUpperCase() ?? '';
    final lowerMessage = (message ?? '').toLowerCase();

    if (isWsHandshakeThrottleError(
        code: normalizedCode, message: lowerMessage)) {
      return false;
    }

    // Let [AuthRefreshLink] retry once before logging out.
    if (normalizedCode == 'TOKEN_EXPIRED' ||
        normalizedCode == 'AUTH_TOKEN_EXPIRED') {
      return false;
    }

    // HTTP 401 / explicit auth errors → sign out.
    if (statusCode == 401) return true;

    if (normalizedCode == 'AUTH_UNAUTHORIZED' ||
        normalizedCode == 'UNAUTHENTICATED' ||
        normalizedCode == 'INVALID_REFRESH_TOKEN' ||
        normalizedCode == 'SESSION_REVOKED') {
      return true;
    }

    if (isGenericUnauthenticatedError(code: code, message: message)) {
      return true;
    }

    if (lowerMessage.contains('token expired') ||
        lowerMessage.contains('jwt expired') ||
        lowerMessage.contains('session expired') ||
        lowerMessage.contains('refresh token') ||
        lowerMessage.contains('jwt must be provided')) {
      return true;
    }

    return false;
  }

  static bool _isPushTokenLifecycleOp(Request request) {
    final name = request.operation.operationName?.toLowerCase() ?? '';
    return name.contains('removedevicetoken') ||
        name.contains('registerdevicetoken');
  }

  static Future<void> _handleUnauthorized(BuildContext context) async {
    if (suppressSessionExpiryHandler) return;

    final now = DateTime.now();
    if (_revokeInFlight) return;
    if (_lastRevokeAt != null &&
        now.difference(_lastRevokeAt!) < const Duration(seconds: 10)) {
      return;
    }

    final token = await _secureStorage.read(key: "authToken");
    if (!context.mounted) return;
    if (token != null && token.isNotEmpty) {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        await auth.clearOrphanBearerIfGuest();
        return;
      }
    }
    if (token == null || token.isEmpty) {
      return;
    }

    _revokeInFlight = true;
    try {
      await onSessionExpired?.call();
      _lastRevokeAt = DateTime.now();
    } finally {
      _revokeInFlight = false;
    }
  }
}
