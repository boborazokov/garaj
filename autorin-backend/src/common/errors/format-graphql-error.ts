import { GraphQLFormattedError } from 'graphql';
import { HttpException } from '@nestjs/common';
import { ApiErrorCode } from './api-error-code.enum';
import { ApiErrorResponse, isApiErrorResponse } from './api-error.response';
import { resolveLegacyCode } from './legacy-message-map';

export type FormatGraphqlErrorOptions = {
  isProduction: boolean;
};

/**
 * Normalizes all GraphQL errors to: extensions.code + optional debug (dev only).
 * Never exposes user-facing translated strings from the backend.
 */
export function formatGraphqlError(
  formattedError: GraphQLFormattedError,
  error: unknown,
  options: FormatGraphqlErrorOptions,
): GraphQLFormattedError {
  const { isProduction } = options;
  const original = (error as { originalError?: unknown })?.originalError ?? error;

  let body: ApiErrorResponse | undefined;
  let httpStatus: number | undefined;

  if (original instanceof HttpException) {
    httpStatus = original.getStatus();
    const response = original.getResponse();
    if (isApiErrorResponse(response)) {
      body = response;
    } else if (typeof response === 'object' && response !== null) {
      const msg = (response as { message?: string | string[] }).message;
      const text = Array.isArray(msg) ? msg.join(', ') : (msg ?? '');
      const code =
        resolveLegacyCode(text) ??
        (httpStatus === 401
          ? ApiErrorCode.AUTH_UNAUTHORIZED
          : httpStatus === 403
            ? ApiErrorCode.AUTH_FORBIDDEN
            : ApiErrorCode.VALIDATION_FAILED);
      body = { success: false, code, debug: text || undefined };
    } else if (typeof response === 'string') {
      const code =
        resolveLegacyCode(response) ?? ApiErrorCode.VALIDATION_FAILED;
      body = { success: false, code, debug: response };
    }
  } else if (original instanceof Error) {
    const code =
      resolveLegacyCode(original.message) ?? ApiErrorCode.INTERNAL_ERROR;
    body = {
      success: false,
      code,
      debug: original.message || undefined,
    };
  }

  if (!body) {
    const message = formattedError.message ?? '';
    const code =
      resolveLegacyCode(message) ?? ApiErrorCode.INTERNAL_ERROR;
    body = {
      success: false,
      code,
      debug: message || undefined,
    };
  }

  const extensions = {
    ...formattedError.extensions,
    success: false,
    code: body.code,
    statusCode: httpStatus ?? formattedError.extensions?.statusCode,
    ...(isProduction ? {} : { debug: body.debug }),
  };

  return {
    ...formattedError,
    message: body.code,
    extensions,
  };
}
