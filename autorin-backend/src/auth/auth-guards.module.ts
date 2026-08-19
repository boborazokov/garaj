import { Global, Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import {
  AuthGuard,
  AuthGuardShared,
  GlobalAuthGuard,
  OptionalAuthGuard,
  WsAuthGuard,
} from './guard';

@Global()
@Module({
  providers: [
    AuthGuardShared,
    AuthGuard,
    OptionalAuthGuard,
    WsAuthGuard,
    GlobalAuthGuard,
    { provide: APP_GUARD, useClass: GlobalAuthGuard },
  ],
  exports: [
    AuthGuardShared,
    AuthGuard,
    OptionalAuthGuard,
    WsAuthGuard,
    GlobalAuthGuard,
  ],
})
export class AuthGuardsModule {}
