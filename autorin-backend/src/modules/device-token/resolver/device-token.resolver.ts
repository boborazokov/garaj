import { Args, Context, Mutation, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import {
  RegisterDeviceTokenArgs,
  RemoveDeviceTokenArgs,
} from '../dto';
import { DeviceToken } from '../schema';
import { DeviceTokenService } from '../service';

@Resolver(() => DeviceToken)
export class DeviceTokenResolver {
  constructor(private readonly service: DeviceTokenService) {}

  /**
   * Called by the mobile client right after a successful login and on
   * every `onTokenRefresh` event from FCM. The mutation is idempotent.
   */
  @UseAuth()
  @Mutation(() => DeviceToken)
  registerDeviceToken(
    @Args() { data }: RegisterDeviceTokenArgs,
    @Context() context: ContextType,
  ): Promise<DeviceToken> {
    const { userId } = assertAuthenticated(context);
    return this.service.register(userId, data);
  }

  /** Called on explicit logout to stop pushing to that device. */
  @UseOptionalAuth()
  @Mutation(() => Boolean)
  removeDeviceToken(
    @Args() { token }: RemoveDeviceTokenArgs,
    @Context() context: ContextType,
  ): Promise<boolean> {
    if (context.userId) {
      return this.service.remove(context.userId, token);
    }
    return this.service.deactivateByToken(token);
  }
}
