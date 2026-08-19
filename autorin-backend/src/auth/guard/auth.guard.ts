import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthGuardShared } from './auth-guard.shared';

/**
 * Strict guard: JWT required. Used for mutations and private data.
 */
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly shared: AuthGuardShared) {}

  canActivate(context: ExecutionContext): boolean {
    const result = this.shared.attachUserToRequest(context);
    return result.ok;
  }
}
