import { ApiErrorCode } from './api-error-code.enum';

/**
 * Maps legacy English HttpException messages to stable codes during migration.
 * Remove entries once the throw site uses throwApi() / ApiException.
 */
export const LEGACY_MESSAGE_TO_CODE: Record<string, ApiErrorCode> = {
  'User already exists': ApiErrorCode.AUTH_USER_EXISTS,
  'User not found': ApiErrorCode.AUTH_USER_NOT_FOUND,
  'Invalid credentials': ApiErrorCode.AUTH_INVALID_CREDENTIALS,
  'Invalid OTP code': ApiErrorCode.AUTH_INVALID_OTP,
  'Confirmation code expired. Request a new code.':
    ApiErrorCode.AUTH_CONFIRMATION_TOKEN_EXPIRED,
  'Missing confirmation token. Complete sign-up again to receive a new code.':
    ApiErrorCode.AUTH_CONFIRMATION_TOKEN_MISSING,
  'Invalid confirmation token. Use the token from the latest signUp response.':
    ApiErrorCode.AUTH_CONFIRMATION_TOKEN_INVALID,
  'Invalid confirmation token': ApiErrorCode.AUTH_CONFIRMATION_TOKEN_INVALID,
  'Order not found': ApiErrorCode.ORDER_NOT_FOUND,
  'Order not found or not closed': ApiErrorCode.ORDER_NOT_CLOSED,
  'Part not found': ApiErrorCode.PART_NOT_FOUND,
  'Workshop not found': ApiErrorCode.WORKSHOP_NOT_FOUND,
  'Service not found': ApiErrorCode.SERVICE_NOT_FOUND,
  'Cannot review your own workshop': ApiErrorCode.BUSINESS_CANNOT_REVIEW_OWN,
  'You already reviewed this workshop': ApiErrorCode.BUSINESS_ALREADY_REVIEWED,
  'You already reviewed this service': ApiErrorCode.BUSINESS_ALREADY_REVIEWED,
  'Not a participant': ApiErrorCode.BUSINESS_NOT_PARTICIPANT,
  'Cannot respond to your own request':
    ApiErrorCode.BUSINESS_CANNOT_RESPOND_OWN_ORDER,
  'Not allowed to watch this order channel':
    ApiErrorCode.BUSINESS_ORDER_WATCH_DENIED,
  'Subscription requires @UseWsAuth() or @Public()':
    ApiErrorCode.AUTH_SUBSCRIPTION_AUTH_REQUIRED,
  UNAUTHENTICATED: ApiErrorCode.WS_UNAUTHENTICATED,
  TOO_MANY_CONNECTIONS: ApiErrorCode.WS_TOO_MANY_CONNECTIONS,
  HANDSHAKE_RATE_LIMITED: ApiErrorCode.WS_HANDSHAKE_RATE_LIMITED,
  ORIGIN_NOT_ALLOWED: ApiErrorCode.WS_ORIGIN_NOT_ALLOWED,
};

export function resolveLegacyCode(message: string): ApiErrorCode | undefined {
  const trimmed = message?.trim();
  if (!trimmed) return undefined;
  if (LEGACY_MESSAGE_TO_CODE[trimmed]) {
    return LEGACY_MESSAGE_TO_CODE[trimmed];
  }
  for (const [pattern, code] of Object.entries(LEGACY_MESSAGE_TO_CODE)) {
    if (trimmed.includes(pattern)) return code;
  }
  return undefined;
}
