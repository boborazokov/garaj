import { applyDecorators, SetMetadata, UseGuards } from '@nestjs/common';
import { WS_SUBSCRIPTION_AUTH_KEY } from '../constants/auth-metadata.constants';
import { WsAuthGuard } from '../guard';

/**
 * GraphQL @Subscription over WebSocket — identity from WS handshake, not HTTP JWT.
 */
export function UseWsAuth(): MethodDecorator {
  return applyDecorators(
    SetMetadata(WS_SUBSCRIPTION_AUTH_KEY, true),
    UseGuards(WsAuthGuard),
  );
}
