import { Types } from 'mongoose';
import { UserRoleEnum } from 'src/modules/user/enums';
import { ContextType } from '../interfaces';

export function isAdminRole(context: ContextType): boolean {
  return context.userRole === UserRoleEnum.ADMIN;
}

/**
 * Regular users may only touch their own documents.
 * An admin may touch any document of that kind.
 */
export function ownerScope(
  context: ContextType,
  ownerField: string,
  ownerId: Types.ObjectId,
): Record<string, Types.ObjectId> {
  if (isAdminRole(context)) return {};
  return { [ownerField]: ownerId };
}
