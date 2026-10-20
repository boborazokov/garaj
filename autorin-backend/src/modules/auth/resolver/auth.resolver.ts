import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { Throttle } from '@nestjs/throttler';
import { Public } from 'src/auth/decorators';
import { AuthService } from '../service';
import {
  ConfirmSignUpArgs,
  LogoutSessionArgs,
  RefreshSessionArgs,
  RequestPasswordResetArgs,
  ResetPasswordArgs,
  SignInArgs,
  SignUpArgs,
} from '../dto';
import { AuthOutput, ConfirmationOutput } from '../types';
import { UseAuth } from 'src/auth/useAuth';
import { ContextType } from 'src/auth/interfaces';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  @Public()
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  @Mutation(() => ConfirmationOutput)
  signUp(@Args() args: SignUpArgs) {
    return this.authService.signUp(args);
  }

  @Public()
  @Throttle({ default: { limit: 12, ttl: 60_000 } })
  @Mutation(() => AuthOutput)
  confirmSignUp(@Args() args: ConfirmSignUpArgs) {
    return this.authService.confirmSignUp(args);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Query(() => AuthOutput)
  signIn(@Args() args: SignInArgs) {
    return this.authService.signIn(args);
  }

  @Public()
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Mutation(() => ConfirmationOutput)
  requestPasswordReset(@Args() args: RequestPasswordResetArgs) {
    return this.authService.requestPasswordReset(args);
  }

  @Public()
  @Throttle({ default: { limit: 12, ttl: 60_000 } })
  @Mutation(() => Boolean)
  resetPassword(@Args() args: ResetPasswordArgs) {
    return this.authService.resetPassword(args);
  }

  @Public()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Mutation(() => AuthOutput)
  refreshSession(@Args() args: RefreshSessionArgs) {
    return this.authService.refreshSession(args.refreshToken, args.deviceId);
  }

  @Public()
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @Mutation(() => Boolean)
  logoutSession(@Args() args: LogoutSessionArgs) {
    return this.authService.logoutSession(args.refreshToken);
  }

  @UseAuth()
  @Mutation(() => Boolean)
  logoutAllDevices(@Context() context: ContextType) {
    return this.authService.logoutAllDevices(context.userId!.toString());
  }
}
