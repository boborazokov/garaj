import { HttpStatus } from '@nestjs/common';
import { Request } from 'express';
import { Types } from 'mongoose';
import { ApiErrorCode, throwApi } from 'src/common/errors';
import { UserRoleEnum } from 'src/modules/user/enums';
import { ContextType } from '../interfaces';

export type AuthenticatedContext = ContextType & {
  userId: Types.ObjectId;
  userRole: UserRoleEnum;
};

/** Reads userId/userRole from GraphQL context root or nested `req`. */
export function resolveAuthenticated(
  context: ContextType,
): AuthenticatedContext | null {
  const req = context.req as Request & Pick<ContextType, 'userId' | 'userRole'>;
  const userId = context.userId ?? req?.userId;
  const userRole = context.userRole ?? req?.userRole;
  if (!userId || !userRole) {
    return null;
  }
  return { ...context, userId, userRole, isAuthenticated: true };
}

export function assertAuthenticated(
  context: ContextType,
): AuthenticatedContext {
  const resolved = resolveAuthenticated(context);
  if (!resolved) {
    throwApi(ApiErrorCode.AUTH_UNAUTHORIZED, {
      status: HttpStatus.UNAUTHORIZED,
      debug: 'Missing or invalid JWT on protected resolver',
    });
  }
  return resolved;
}
