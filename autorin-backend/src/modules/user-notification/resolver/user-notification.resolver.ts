import { Args, Context, Int, Mutation, Query, Resolver } from '@nestjs/graphql';
import { UseAuth } from 'src/auth/useAuth';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { GetMyNotificationsArgs } from '../dto/args/get-my-notifications.args';
import { MarkNotificationReadArgs } from '../dto/args/mark-notification-read.args';
import { UserNotificationService } from '../service/user-notification.service';
import { PaginatedUserNotifications } from '../types';

@Resolver()
export class UserNotificationResolver {
  constructor(private readonly service: UserNotificationService) {}

  @UseAuth()
  @Query(() => PaginatedUserNotifications, { name: 'getMyNotifications' })
  getMyNotifications(
    @Args() args: GetMyNotificationsArgs,
    @Context() ctx: ContextType,
  ) {
    const { userId } = assertAuthenticated(ctx);
    return this.service.listForUser(userId.toString(), args.pagination);
  }

  @UseAuth()
  @Query(() => Int, { name: 'myUnreadNotificationsCount' })
  myUnreadNotificationsCount(@Context() ctx: ContextType) {
    const { userId } = assertAuthenticated(ctx);
    return this.service.unreadCount(userId.toString());
  }

  @UseAuth()
  @Mutation(() => Boolean, { name: 'markNotificationRead' })
  markNotificationRead(
    @Args() args: MarkNotificationReadArgs,
    @Context() ctx: ContextType,
  ) {
    const { userId } = assertAuthenticated(ctx);
    return this.service.markRead(
      userId.toString(),
      args.notificationId.toString(),
    );
  }

  @UseAuth()
  @Mutation(() => Int, { name: 'markAllNotificationsRead' })
  markAllNotificationsRead(@Context() ctx: ContextType) {
    const { userId } = assertAuthenticated(ctx);
    return this.service.markAllRead(userId.toString());
  }
}
