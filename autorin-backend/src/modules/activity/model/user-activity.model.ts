import { UserActivity, UserActivitySchema } from '../schema';
import { COLLECTIONS } from 'src/constants';

export const UserActivityModel = {
  name: COLLECTIONS.USER_ACTIVITIES,
  schema: UserActivitySchema,
};
