import { UserRoleEnum } from 'src/modules/user/enums';

export interface AuthTokenPayload {
  userId: string;
  userRole: UserRoleEnum;
}
