import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/auth_coordinator.dart';
import 'package:my_auto/core/services/graphql/public_auth_operations.dart';

/// TOKEN_EXPIRED → single-flight refresh → one retry (no infinite loops).
class AuthRefreshLink extends Link {
  static final Set<String> _retriedOperationKeys = {};

  static String _retryKey(Request request) {
    final name = request.operation.operationName ?? 'anonymous';
    return '$name:${jsonEncode(request.variables)}';
  }

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final next = forward;
    if (next == null) return;

    final retryKey = _retryKey(request);
    final alreadyRetried = _retriedOperationKeys.contains(retryKey);

    await for (final response in next(request)) {
      final shouldRefresh = !alreadyRetried &&
          !isPublicAuthOperation(request) &&
          _isExpired(response);

      if (!shouldRefresh) {
        yield response;
        continue;
      }

      final refreshed =
          await AuthCoordinator.instance.refreshSession(force: true);
      if (!refreshed) {
        await AuthCoordinator.onRefreshFailed?.call();
        yield response;
        continue;
      }

      _retriedOperationKeys.add(retryKey);
      try {
        yield* next(request);
      } finally {
        _retriedOperationKeys.remove(retryKey);
      }
      return;
    }
  }

  bool _isExpired(Response response) {
    final errors = response.errors;
    if (errors == null || errors.isEmpty) return false;
    for (final e in errors) {
      if (AuthCoordinator.instance.shouldRefreshForGraphQLError(
        code: e.extensions?['code']?.toString(),
        message: e.message,
      )) {
        return true;
      }
    }
    return false;
  }
}

/// Blocks subscription socket when there is no access token.
class WebSocketAuthGateLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    if (request.isSubscription) {
      final token = AuthCoordinator.instance.accessToken;
      if (token == null || token.isEmpty) {
        yield* Stream.error(
          OperationException(
            graphqlErrors: [
              GraphQLError(
                message: 'WebSocket requires authentication',
                extensions: const {'code': 'UNAUTHENTICATED'},
              ),
            ],
          ),
        );
        return;
      }
    }
    yield* forward!(request);
  }
}
