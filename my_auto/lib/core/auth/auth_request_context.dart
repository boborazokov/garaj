/// GraphQL [Request.context] keys for auth link behavior.
abstract final class AuthRequestContext {
  /// Set to `true` after one post-refresh retry — prevents infinite loops.
  static const alreadyRetried = 'auth_already_retried';
}
