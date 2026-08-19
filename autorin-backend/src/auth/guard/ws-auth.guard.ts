import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Logger,
} from '@nestjs/common';
import { Types } from 'mongoose';
import { UserRoleEnum } from 'src/modules/user/enums';
import { ContextType } from '../interfaces';

/**
 * Auth guard for GraphQL Subscription handlers running over WebSocket
 * (`graphql-ws` transport).
 *
 * Unlike `AuthGuard`, this guard does NOT decode the JWT itself.
 * The token has already been verified in `subscriptions.onConnect` (see
 * `graphql.config.ts`) and the decoded identity was attached to
 * `connection.extra`. By the time the GraphQL Context Factory runs we
 * forward those fields into the resolver context. Here we just assert
 * they're present — if `onConnect` rejected the handshake we never
 * arrive here anyway.
 *
 * We split this from the HTTP `AuthGuard` because:
 *  - HTTP guard reads `req.headers.authorization`; over WS there is no
 *    per-operation header, only the initial `connectionParams`.
 *  - Re-verifying the JWT on every published message would be expensive
 *    and would also break logout-on-revoke semantics (the right place
 *    to revoke a subscription is the WS close, not per-message).
 */
@Injectable()
export class WsAuthGuard implements CanActivate {
  private readonly logger = new Logger('WsAuthGuard');

  canActivate(execContext: ExecutionContext): boolean {
    // For GraphQL resolvers Nest exposes the GraphQL `context` argument
    // as the third RPC arg. Same trick the existing `AuthGuard` uses.
    const rpcCall = execContext.switchToRpc() || { args: [] as unknown[] };
    const gqlContext = (rpcCall['args'] as unknown[])[2] as
      | Partial<ContextType>
      | undefined;

    const userId = gqlContext?.userId as Types.ObjectId | undefined;
    const userRole = gqlContext?.userRole as UserRoleEnum | undefined;

    if (!userId || !Types.ObjectId.isValid(userId.toString()) || !userRole) {
      this.logger.warn('Rejected WS resolver call: missing/invalid userId');
      return false;
    }
    return true;
  }
}
