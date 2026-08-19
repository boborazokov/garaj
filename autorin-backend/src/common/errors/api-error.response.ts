import { ApiErrorCode } from './api-error-code.enum';

/** Canonical API error body (GraphQL extensions + REST JSON). */
export interface ApiErrorResponse {
  success: false;
  code: ApiErrorCode;
  /** English developer hint — never shown to end users in production clients. */
  debug?: string;
}

export interface ApiSuccessResponse<T = unknown> {
  success: true;
  data: T;
}

export function isApiErrorResponse(
  value: unknown,
): value is ApiErrorResponse {
  if (!value || typeof value !== 'object') return false;
  const o = value as Record<string, unknown>;
  return o.success === false && typeof o.code === 'string';
}
