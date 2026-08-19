import { Request } from 'express';
import { Types } from 'mongoose';
import { UserRoleEnum } from 'src/modules/user/enums';

export interface ContextType {
  req: Request;
  /** Present when a valid JWT was sent (strict or optional auth). */
  userId?: Types.ObjectId;
  userRole?: UserRoleEnum;
  /** Set by auth guards on every GraphQL HTTP request. */
  isAuthenticated?: boolean;
}
