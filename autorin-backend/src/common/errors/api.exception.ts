import { HttpException, HttpStatus } from '@nestjs/common';
import { ApiErrorCode } from './api-error-code.enum';
import { ApiErrorResponse } from './api-error.response';

export class ApiException extends HttpException {
  readonly apiCode: ApiErrorCode;
  readonly debug?: string;

  constructor(
    code: ApiErrorCode,
    options?: {
      status?: HttpStatus;
      debug?: string;
    },
  ) {
    const status = options?.status ?? HttpStatus.BAD_REQUEST;
    const body: ApiErrorResponse = {
      success: false,
      code,
      debug: options?.debug,
    };
    super(body, status);
    this.apiCode = code;
    this.debug = options?.debug;
  }
}

/** Throws an [ApiException] with a stable code (preferred over raw English messages). */
export function throwApi(
  code: ApiErrorCode,
  options?: { status?: HttpStatus; debug?: string },
): never {
  throw new ApiException(code, options);
}
