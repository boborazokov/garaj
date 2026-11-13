import { GraphQLError } from 'graphql';
import { UnauthorizedException } from '@nestjs/common';
import { ApiErrorCode } from './api-error-code.enum';
import { formatGraphqlError } from './format-graphql-error';
import { ApiException } from './api.exception';

describe('formatGraphqlError', () => {
  it('strips stacktrace from Apollo-formatted errors in production', () => {
    const formatted = {
      message: 'AUTH_INVALID_CREDENTIALS',
      extensions: {
        code: 'AUTH_INVALID_CREDENTIALS',
        stacktrace: [
          'Error: secret',
          '    at D:\\flutter_projects\\Garaje\\autorin-backend\\src\\foo.ts:1:1',
        ],
      },
    };
    const err = new ApiException(ApiErrorCode.AUTH_INVALID_CREDENTIALS);
    const out = formatGraphqlError(formatted as any, err, {
      isProduction: true,
    });
    expect(out.message).toBe(ApiErrorCode.AUTH_INVALID_CREDENTIALS);
    expect(out.extensions?.stacktrace).toBeUndefined();
    expect(out.extensions?.debug).toBeUndefined();
    expect(JSON.stringify(out)).not.toMatch(/flutter_projects|stacktrace/i);
  });

  it('maps GraphQL validation failures to VALIDATION_FAILED without INTERNAL_ERROR', () => {
    const formatted = {
      message: 'Cannot query field "me" on type "Query".',
      extensions: { code: 'GRAPHQL_VALIDATION_FAILED' },
    };
    const gqlErr = new GraphQLError('Cannot query field "me" on type "Query".', {
      extensions: { code: 'GRAPHQL_VALIDATION_FAILED' },
    });
    const out = formatGraphqlError(formatted as any, gqlErr, {
      isProduction: true,
    });
    expect(out.message).toBe(ApiErrorCode.VALIDATION_FAILED);
    expect(out.extensions?.code).toBe(ApiErrorCode.VALIDATION_FAILED);
    expect(out.extensions?.stacktrace).toBeUndefined();
  });

  it('maps unauthorized HttpException to AUTH_UNAUTHORIZED', () => {
    const formatted = { message: 'Unauthorized', extensions: {} };
    const out = formatGraphqlError(
      formatted as any,
      new UnauthorizedException(),
      { isProduction: true },
    );
    expect(out.extensions?.code).toBe(ApiErrorCode.AUTH_UNAUTHORIZED);
    expect(out.extensions?.stacktrace).toBeUndefined();
  });
});
