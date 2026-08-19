import { ExecutionContext, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GqlExecutionContext } from '@nestjs/graphql';
import { Request } from 'express';
import * as jwt from 'jsonwebtoken';
import { Types } from 'mongoose';
import { UserRoleEnum } from 'src/modules/user/enums';
import { AuthTokenPayload, ContextType } from '../interfaces';
import { ROLE_METADATA } from '../role';

export type AttachUserResult =
  | { ok: true; payload: AuthTokenPayload }
  | { ok: false };

/**
 * Shared JWT extraction / request mutation used by strict and optional guards.
 */
@Injectable()
export class AuthGuardShared {
  constructor(protected readonly configService: ConfigService) {}

  extractTokenFromRequest(req: Request & Partial<ContextType>): string | undefined {
    const [type, token] = req.headers?.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }

  extractRequestFromContext(context: ExecutionContext): Request & Partial<ContextType> {
    if (context.getType<string>() === 'graphql') {
      const gqlCtx = GqlExecutionContext.create(context).getContext<
        Request & Partial<ContextType>
      >();
      return (gqlCtx?.req ?? gqlCtx) as Request & Partial<ContextType>;
    }
    return context.switchToHttp().getRequest();
  }

  extractRequiredRoles(target: Function, resolverName: string): UserRoleEnum[] {
    const roles = Reflect.getMetadata(
      ROLE_METADATA,
      target,
      resolverName,
    ) as UserRoleEnum[];
    return roles || [];
  }

  decodeToken(token?: string): false | AuthTokenPayload {
    if (!token) return false;

    const secret = this.configService.getOrThrow<string>('JWT_SECRET');

    try {
      const decodedToken = jwt.verify(token, secret) as AuthTokenPayload;

      if (!decodedToken || typeof decodedToken === 'string') return false;

      const isTokenPayloadValid =
        decodedToken.userId &&
        Types.ObjectId.isValid(decodedToken.userId) &&
        decodedToken.userRole &&
        UserRoleEnum[decodedToken.userRole];

      return isTokenPayloadValid ? decodedToken : false;
    } catch {
      return false;
    }
  }

  /**
   * Attaches `userId` / `userRole` / `isAuthenticated` onto the request when a
   * valid Bearer token is present. Always sets `isAuthenticated`.
   */
  attachUserToRequest(context: ExecutionContext): AttachUserResult {
    const resolverClass = context.getClass();
    const resolver = context.getHandler();
    const request = this.extractRequestFromContext(context);

    if (request.isAuthenticated && request.userId) {
      return {
        ok: true,
        payload: {
          userId: request.userId.toString(),
          userRole: request.userRole!,
        },
      };
    }

    const token = this.extractTokenFromRequest(request);
    const tokenPayload = this.decodeToken(token);

    if (!token || !tokenPayload) {
      Object.assign(request, {
        isAuthenticated: false,
      } satisfies Partial<ContextType>);
      return { ok: false };
    }

    const requiredRoles = this.extractRequiredRoles(
      resolverClass,
      resolver.name,
    );

    if (
      requiredRoles.length &&
      !requiredRoles.includes(tokenPayload.userRole)
    ) {
      Object.assign(request, {
        isAuthenticated: false,
      } satisfies Partial<ContextType>);
      return { ok: false };
    }

    const authFields = {
      userId: new Types.ObjectId(tokenPayload.userId),
      userRole: tokenPayload.userRole,
      isAuthenticated: true,
    } satisfies Partial<ContextType>;

    Object.assign(request, authFields);

    // Keep @Context() and guards in sync when gql context is { req, res, … }.
    if (context.getType<string>() === 'graphql') {
      const gqlCtx = GqlExecutionContext.create(context).getContext<
        Partial<ContextType>
      >();
      if (gqlCtx && gqlCtx !== request) {
        Object.assign(gqlCtx, authFields, { req: request });
      }
    }

    return { ok: true, payload: tokenPayload };
  }
}
