import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GqlArgumentsHost } from '@nestjs/graphql';
import { Request, Response } from 'express';
import { isProductionEnv } from 'src/configs/env';
import { ApiErrorCode, isApiErrorResponse } from 'src/common/errors';

const SENSITIVE_KEYS = /password|token|secret|authorization|cookie|api[_-]?key/i;

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  constructor(private readonly config: ConfigService) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const isProd = isProductionEnv(this.config.get<string>('NODE_ENV'));
    const gqlHost = GqlArgumentsHost.create(host);
    const isGraphQL = gqlHost.getType<string>() === 'graphql';

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const responseBody =
      exception instanceof HttpException
        ? exception.getResponse()
        : { message: 'Internal server error' };

    const message =
      typeof responseBody === 'string'
        ? responseBody
        : ((responseBody as { message?: string | string[] }).message ??
          'Internal server error');

    if (!isProd) {
      this.logger.error(
        exception instanceof Error ? exception.stack : String(exception),
      );
    } else {
      this.logger.error(
        `HTTP ${status}: ${Array.isArray(message) ? message.join(', ') : message}`,
      );
    }

    if (isGraphQL) {
      throw exception;
    }

    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    if (
      typeof responseBody === 'object' &&
      responseBody !== null &&
      isApiErrorResponse(responseBody)
    ) {
      response.status(status).json({
        ...responseBody,
        ...(isProd ? { debug: undefined } : {}),
        timestamp: new Date().toISOString(),
        path: request.url,
      });
      return;
    }

    const safeMessage = isProd
      ? status >= 500
        ? 'Internal server error'
        : Array.isArray(message)
          ? message
          : message
      : message;

    response.status(status).json({
      success: false,
      code:
        status >= 500
          ? ApiErrorCode.INTERNAL_ERROR
          : status === 401
            ? ApiErrorCode.AUTH_UNAUTHORIZED
            : status === 403
              ? ApiErrorCode.AUTH_FORBIDDEN
              : ApiErrorCode.VALIDATION_FAILED,
      debug: isProd ? undefined : safeMessage,
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      ...(isProd ? {} : { stack: exception instanceof Error ? exception.stack : undefined }),
    });
  }

  /** Use in custom log payloads to strip secrets before writing to logs. */
  static sanitizeForLog(payload: Record<string, unknown>): Record<string, unknown> {
    const out: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(payload)) {
      if (SENSITIVE_KEYS.test(key)) {
        out[key] = '[redacted]';
      } else if (value && typeof value === 'object' && !Array.isArray(value)) {
        out[key] = HttpExceptionFilter.sanitizeForLog(
          value as Record<string, unknown>,
        );
      } else {
        out[key] = value;
      }
    }
    return out;
  }
}
