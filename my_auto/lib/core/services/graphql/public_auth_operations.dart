import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// GraphQL operation names whose document MUST be sent without a session
/// Bearer token (so a stale JWT can't break OTP signup / sign-in).
const Set<String> publicAuthOperationNames = {
  'signUp',
  'confirmSignUp',
  'signIn',
  'RequestPasswordReset',
  'requestPasswordReset',
  'ResetPassword',
  'resetPassword',
  'RefreshSession',
  'refreshSession',
  'RegisterDeviceToken',
  'registerDeviceToken',
  'RemoveDeviceToken',
  'removeDeviceToken',
  'LogoutSession',
  'logoutSession',
  'ContactInfo',
  'contactInfo',
};

/// Backend `@Public()` catalog + auth (no JWT).
const Set<String> _publicAuthRootFields = {
  'signup',
  'confirmsignup',
  'signin',
  'requestpasswordreset',
  'resetpassword',
  'getcategories',
  'getcategorytree',
  'workshopcategories',
  'servicecategories',
  'getviewscount',
  'contactinfo',
};

/// True for GraphQL query operations (not mutation/subscription).
bool isQueryOperation(Request request) {
  for (final def in request.operation.document.definitions) {
    if (def is OperationDefinitionNode) {
      return def.type == OperationType.query;
    }
  }
  return false;
}

bool isPublicAuthOperation(Request request) {
  final name = request.operation.operationName?.trim() ?? '';
  if (name.isNotEmpty) {
    return publicAuthOperationNames
        .any((n) => name.toLowerCase() == n.toLowerCase());
  }
  return _documentHasPublicAuthRootField(request.operation.document);
}

bool _documentHasPublicAuthRootField(DocumentNode document) {
  for (final def in document.definitions) {
    if (def is! OperationDefinitionNode) continue;
    for (final selection in def.selectionSet.selections) {
      if (selection is FieldNode) {
        if (_publicAuthRootFields.contains(selection.name.value.toLowerCase())) {
          return true;
        }
      }
    }
  }
  return false;
}

bool isGenericUnauthenticatedError({String? code, String? message}) {
  final c = (code ?? '').toUpperCase();
  if (c == 'UNAUTHENTICATED') return true;
  final m = (message ?? '').toLowerCase();
  return m.contains('unauthorized') ||
      m.contains('not authenticated') ||
      m == 'unauthenticated';
}

bool isAuthLifecycleGraphQLError(String message) {
  final m = message.toLowerCase();
  return m.contains('jwt must be provided') ||
      m.contains('missing confirmation token') ||
      m.contains('invalid confirmation token') ||
      m.contains('confirmation code expired') ||
      m.contains('invalid or expired confirmation');
}

bool isWsHandshakeThrottleError({String? code, String? message}) {
  final c = (code ?? '').toUpperCase();
  if (c == 'HANDSHAKE_RATE_LIMITED' || c.contains('HANDSHAKE')) {
    return true;
  }
  final m = (message ?? '').toLowerCase();
  return m.contains('handshake') &&
      (m.contains('throttl') || m.contains('rate limit'));
}
