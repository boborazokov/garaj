import { UserNotification, UserNotificationSchema } from '../schema/user-notification.schema';
import { COLLECTIONS } from 'src/constants';

export const UserNotificationModel = {
  name: COLLECTIONS.USER_NOTIFICATIONS,
  schema: UserNotificationSchema,
  collection: 'user_notifications',
};

export type { UserNotification };
