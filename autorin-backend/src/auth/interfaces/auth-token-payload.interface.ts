import { UserRoleEnum } from 'src/modules/user/enums';

export interface AuthTokenPayload {
  userId: string;
  userRole: UserRoleEnum;
  /** Present on access tokens issued with server-side sessions. */
  sid?: string;
  typ?: 'access';
  exp?: number;
  iat?: number;
}
