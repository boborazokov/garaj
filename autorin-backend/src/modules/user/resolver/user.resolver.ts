import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { UserService } from '../service';
import { UseAuth } from 'src/auth/useAuth';
import { ContextType } from 'src/auth/interfaces';
import { User } from '../schema';
import { UpdateProfileArgs } from '../dto';
import { DeleteAccountResult } from '../types';

@Resolver()
export class UserResolver {
  constructor(private userService: UserService) {}

  @Query(() => User)
  @UseAuth()
  getProfile(@Context() context: ContextType) {
    return this.userService.getProfile(context);
  }

  @Mutation(() => User)
  @UseAuth()
  updateProfile(
    @Args() args: UpdateProfileArgs,
    @Context() context: ContextType,
  ) {
    return this.userService.updateProfile(args, context);
  }

  @Mutation(() => DeleteAccountResult)
  @UseAuth()
  deleteMyAccount(@Context() context: ContextType) {
    return this.userService.deleteMyAccount(context);
  }
}
