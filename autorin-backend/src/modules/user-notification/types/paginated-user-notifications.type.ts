import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { UserNotificationType } from './user-notification.type';

@ObjectType()
export class PaginatedUserNotifications extends PaginationResult {
  @Field(() => [UserNotificationType])
  payload: UserNotificationType[];
}
