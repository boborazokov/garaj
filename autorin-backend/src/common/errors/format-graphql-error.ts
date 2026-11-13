import { GraphQLError, GraphQLFormattedError } from 'graphql';
import { HttpException } from '@nestjs/common';
import { ApiErrorCode } from './api-error-code.enum';
import { ApiErrorResponse, isApiErrorResponse } from './api-error.response';
import { resolveLegacyCode } from './legacy-message-map';

export type FormatGraphqlErrorOptions = {
  isProduction: boolean;
  /** When true, include a non-sensitive `debug` hint (never stacktraces). */
  includeDebug?: boolean;
};

const SENSITIVE_KEY =
  /stack|stacktrace|path|exception|trace|syscall|address|password|token|secret|otp|authorization/i;

function isGraphqlValidationError(error: unknown, formatted: GraphQLFormattedError): boolean {
  const original = (error as { originalError?: unknown })?.originalError ?? error;
  if (original instanceof GraphQLError) {
    const name = (original as { name?: string }).name ?? '';
    if (/GraphQLError/i.test(name) && !(original.originalError instanceof HttpException)) {
      // Validation / syntax / field errors are GraphQLErrors without HttpException cause
      const code = formatted.extensions?.code;
      if (
        code === 'GRAPHQL_VALIDATION_FAILED' ||
        code === 'GRAPHQL_PARSE_FAILED' ||
        code === 'BAD_USER_INPUT' ||
        typeof code === 'undefined'
      ) {
        // Distinguishing: Apollo sets extensions.code for validation
        return (
          code === 'GRAPHQL_VALIDATION_FAILED' ||
          code === 'GRAPHQL_PARSE_FAILED' ||
          code === 'BAD_USER_INPUT' ||
          /Cannot query field|Syntax Error|Unknown type|Field \".*\" argument/i.test(
            formatted.message ?? '',
          )
        );
      }
    }
  }
  const extCode = formatted.extensions?.code;
  return (
    extCode === 'GRAPHQL_VALIDATION_FAILED' ||
    extCode === 'GRAPHQL_PARSE_FAILED' ||
    extCode === 'BAD_USER_INPUT'
  );
}

/**
 * Normalizes all GraphQL errors to: extensions.code (+ optional debug in local only).
 * Never exposes stacktraces, filesystem paths, or secrets to clients.
 */
export function formatGraphqlError(
  formattedError: GraphQLFormattedError,
  error: unknown,
  options: FormatGraphqlErrorOptions,
): GraphQLFormattedError {
  const { isProduction } = options;
  const includeDebug = options.includeDebug ?? !isProduction;
  const original = (error as { originalError?: unknown })?.originalError ?? error;

  let body: ApiErrorResponse | undefined;
  let httpStatus: number | undefined;

  if (isGraphqlValidationError(error, formattedError)) {
    body = {
      success: false,
      code: ApiErrorCode.VALIDATION_FAILED,
      debug: includeDebug ? formattedError.message : undefined,
    };
  } else if (original instanceof HttpException) {
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
      debug: includeDebug ? original.message || undefined : undefined,
    };
  }

  if (!body) {
    const message = formattedError.message ?? '';
    const code =
      resolveLegacyCode(message) ?? ApiErrorCode.INTERNAL_ERROR;
    body = {
      success: false,
      code,
      debug: includeDebug ? message || undefined : undefined,
    };
  }

  // Rebuild extensions from scratch — do not inherit Apollo stacktrace / exception paths.
  const safeExtensions: Record<string, unknown> = {
    success: false,
    code: body.code,
  };
  if (httpStatus != null) {
    safeExtensions.statusCode = httpStatus;
  }
  if (includeDebug && body.debug && !SENSITIVE_KEY.test(body.debug)) {
    // Strip absolute Windows/Unix paths from any debug string
    const scrubbed = body.debug
      .replace(/[A-Za-z]:\\[^\s:)+]+/g, '[path]')
      .replace(/\/(?:Users|home|var|tmp|opt)\/[^\s:)+]+/g, '[path]');
    safeExtensions.debug = scrubbed;
  }

  return {
    message: body.code,
    locations: formattedError.locations,
    path: formattedError.path,
    extensions: safeExtensions,
  };
}
