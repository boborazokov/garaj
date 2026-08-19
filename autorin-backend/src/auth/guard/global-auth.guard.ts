import { CanActivate, ExecutionContext, HttpStatus, Injectable } from '@nestjs/common';
import { ApiErrorCode, throwApi } from 'src/common/errors';
import { Reflector } from '@nestjs/core';
import { GqlExecutionContext } from '@nestjs/graphql';
import {
  IS_OPTIONAL_AUTH_KEY,
  IS_PUBLIC_KEY,
  WS_SUBSCRIPTION_AUTH_KEY,
} from '../constants/auth-metadata.constants';
import { AuthGuardShared } from './auth-guard.shared';
import { WsAuthGuard } from './ws-auth.guard';

/**
 * Secure-by-default: every HTTP route and GraphQL root field requires a valid
 * JWT unless marked {@link Public} or {@link UseOptionalAuth}.
 *
 * GraphQL **field resolvers** (`@ResolveField`) run after a parent object was
 * already resolved; auth was enforced on the root Query/Mutation/Subscription.
 * Skipping JWT here avoids breaking public catalog queries that nest fields.
 *
 * GraphQL **Subscription** root fields use WS identity from `onConnect`, not
 * the HTTP `Authorization` header — handlers marked with {@link UseWsAuth} are
 * delegated to {@link WsAuthGuard}.
 */
@Injectable()
export class GlobalAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly shared: AuthGuardShared,
    private readonly wsAuthGuard: WsAuthGuard,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const isOptional = this.reflector.getAllAndOverride<boolean>(
      IS_OPTIONAL_AUTH_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (context.getType<string>() === 'graphql') {
      const gqlCtx = GqlExecutionContext.create(context);
      const info = gqlCtx.getInfo();

      // Nested @ResolveField only (path.prev set). Root Query/Mutation/Subscription
      // have path.prev === undefined — must not skip JWT here (parentType.name
      // alone is unreliable with @Resolver(() => SomeType) class decorators).
      const isNestedFieldResolver = Boolean(info?.path?.prev);
      if (isNestedFieldResolver) {
        if (isOptional) {
          this.shared.attachUserToRequest(context);
        }
        return true;
      }

      if (info?.parentType?.name === 'Subscription') {
        const wsStrict = this.reflector.getAllAndOverride<boolean>(
          WS_SUBSCRIPTION_AUTH_KEY,
          [context.getHandler(), context.getClass()],
        );
        if (wsStrict) {
          return this.wsAuthGuard.canActivate(context);
        }
        throwApi(ApiErrorCode.AUTH_SUBSCRIPTION_AUTH_REQUIRED, {
          status: HttpStatus.UNAUTHORIZED,
          debug: 'Subscription missing @UseWsAuth() or @Public()',
        });
      }
    }

    if (isOptional) {
      this.shared.attachUserToRequest(context);
      return true;
    }

    const result = this.shared.attachUserToRequest(context);
    if (!result.ok) {
      throwApi(ApiErrorCode.AUTH_UNAUTHORIZED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'JWT missing or invalid',
      });
    }
    return true;
  }
}
