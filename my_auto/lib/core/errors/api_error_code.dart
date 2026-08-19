/// Stable codes returned by the backend in GraphQL `extensions.code`.
/// Must stay in sync with autorin-backend `ApiErrorCode` enum.
enum ApiErrorCode {
  authUnauthorized('AUTH_UNAUTHORIZED'),
  authForbidden('AUTH_FORBIDDEN'),
  authUserExists('AUTH_USER_EXISTS'),
  authUserNotFound('AUTH_USER_NOT_FOUND'),
  authInvalidCredentials('AUTH_INVALID_CREDENTIALS'),
  authInvalidOtp('AUTH_INVALID_OTP'),
  authOtpExpired('AUTH_OTP_EXPIRED'),
  authConfirmationTokenMissing('AUTH_CONFIRMATION_TOKEN_MISSING'),
  authConfirmationTokenInvalid('AUTH_CONFIRMATION_TOKEN_INVALID'),
  authConfirmationTokenExpired('AUTH_CONFIRMATION_TOKEN_EXPIRED'),
  authTokenExpired('AUTH_TOKEN_EXPIRED'),
  authSubscriptionAuthRequired('AUTH_SUBSCRIPTION_AUTH_REQUIRED'),

  validationFailed('VALIDATION_FAILED'),
  validationFileTooLarge('VALIDATION_FILE_TOO_LARGE'),
  validationFileTypeInvalid('VALIDATION_FILE_TYPE_INVALID'),
  validationGraphqlBodyTooLarge('VALIDATION_GRAPHQL_BODY_TOO_LARGE'),
  validationGraphqlComplexity('VALIDATION_GRAPHQL_COMPLEXITY'),

  resourceNotFound('RESOURCE_NOT_FOUND'),
  orderNotFound('ORDER_NOT_FOUND'),
  orderNotClosed('ORDER_NOT_CLOSED'),
  partNotFound('PART_NOT_FOUND'),
  workshopNotFound('WORKSHOP_NOT_FOUND'),
  serviceNotFound('SERVICE_NOT_FOUND'),
  conversationNotFound('CONVERSATION_NOT_FOUND'),
  messageNotFound('MESSAGE_NOT_FOUND'),
  userNotFound('USER_NOT_FOUND'),

  businessNotParticipant('BUSINESS_NOT_PARTICIPANT'),
  businessNotAllowed('BUSINESS_NOT_ALLOWED'),
  businessCannotReviewOwn('BUSINESS_CANNOT_REVIEW_OWN'),
  businessAlreadyReviewed('BUSINESS_ALREADY_REVIEWED'),
  businessCannotBookOwn('BUSINESS_CANNOT_BOOK_OWN'),
  businessCannotRespondOwnOrder('BUSINESS_CANNOT_RESPOND_OWN_ORDER'),
  businessOrderWatchDenied('BUSINESS_ORDER_WATCH_DENIED'),
  businessMessageTooLong('BUSINESS_MESSAGE_TOO_LONG'),
  businessRateLimit('BUSINESS_RATE_LIMIT'),

  wsUnauthenticated('WS_UNAUTHENTICATED'),
  wsTooManyConnections('WS_TOO_MANY_CONNECTIONS'),
  wsHandshakeRateLimited('WS_HANDSHAKE_RATE_LIMITED'),
  wsOriginNotAllowed('WS_ORIGIN_NOT_ALLOWED'),
  deviceOffline('DEVICE_OFFLINE'),

  internalError('INTERNAL_ERROR'),
  unknown('UNKNOWN');

  const ApiErrorCode(this.wireValue);
  final String wireValue;

  static ApiErrorCode? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.trim().toUpperCase();
    for (final code in ApiErrorCode.values) {
      if (code.wireValue == normalized) return code;
    }
    return null;
  }
}
