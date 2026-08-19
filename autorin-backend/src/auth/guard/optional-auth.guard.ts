import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthGuardShared } from './auth-guard.shared';

/**
 * Guest-first guard: always allows the request.
 *
 * - No token → public browse (isAuthenticated = false)
 * - Valid token → userId attached (isAuthenticated = true)
 * - Invalid/expired token → treated as guest (does NOT throw)
 */
@Injectable()
export class OptionalAuthGuard implements CanActivate {
  constructor(private readonly shared: AuthGuardShared) {}

  canActivate(context: ExecutionContext): boolean {
    this.shared.attachUserToRequest(context);
    return true;
  }
}
