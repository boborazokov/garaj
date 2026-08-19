import { Args, Mutation, Query, Resolver } from '@nestjs/graphql';
import { Public } from 'src/auth/decorators';
import { AuthService } from '../service';
import { ConfirmSignUpArgs, SignInArgs, SignUpArgs } from '../dto';
import { AuthOutput, ConfirmationOutput } from '../types';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  @Public()
  @Mutation(() => ConfirmationOutput)
  signUp(@Args() args: SignUpArgs) {
    return this.authService.signUp(args);
  }

  @Public()
  @Mutation(() => AuthOutput)
  confirmSignUp(@Args() args: ConfirmSignUpArgs) {
    return this.authService.confirmSignUp(args);
  }

  @Public()
  @Query(() => AuthOutput)
  signIn(@Args() args: SignInArgs) {
    return this.authService.signIn(args);
  }
}
