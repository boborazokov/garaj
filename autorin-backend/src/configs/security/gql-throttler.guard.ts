import { ExecutionContext, Injectable } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { ThrottlerGuard } from '@nestjs/throttler';
import { Request, Response } from 'express';

type ReqLike = {
  ip?: string;
  headers?: Record<string, string | string[] | undefined>;
  socket?: { remoteAddress?: string };
  res?: Response;
};

/**
 * Default {@link ThrottlerGuard} only supports HTTP (`switchToHttp()`).
 * GraphQL resolvers use a different execution context — `req` was undefined,
 * causing `Cannot read properties of undefined (reading 'ip')` and breaking
 * all Flutter/API queries.
 */
@Injectable()
export class GqlThrottlerGuard extends ThrottlerGuard {
  protected getRequestResponse(context: ExecutionContext) {
    if (context.getType<string>() === 'graphql') {
      const gqlCtx = GqlExecutionContext.create(context);
      const ctx = gqlCtx.getContext<{
        req?: Request;
        res?: Response;
        userId?: { toString(): string };
        headers?: Request['headers'];
      }>();

      const req: ReqLike | undefined =
        ctx?.req ??
        (ctx?.headers ? (ctx as unknown as Request) : undefined);

      if (req) {
        const res = ctx?.res ?? req.res;
        return {
          req,
          res: res ?? { header: () => undefined },
        };
      }

      const trackerId = ctx?.userId?.toString() ?? 'anonymous';
      return {
        req: { ip: `gql:${trackerId}`, headers: {} },
        res: { header: () => undefined },
      };
    }

    return super.getRequestResponse(context) as {
      req: ReqLike;
      res: { header: (name: string, value?: string | number) => void };
    };
  }

  protected async getTracker(req: ReqLike): Promise<string> {
    if (!req) return 'unknown';

    const forwarded = req.headers?.['x-forwarded-for'];
    const forwardedIp =
      typeof forwarded === 'string'
        ? forwarded.split(',')[0]?.trim()
        : undefined;

    return (
      req.ip ??
      forwardedIp ??
      req.socket?.remoteAddress ??
      'unknown'
    );
  }
}
