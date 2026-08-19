import { applyDecorators } from '@nestjs/common';
import { UserRoleEnum } from 'src/modules/user/enums';
import { Role } from '../role';
import { UseAuth } from './use-auth.decorator';

/** Requires JWT and one of the given roles. */
export function UseRole(...roles: UserRoleEnum[]): MethodDecorator {
  return applyDecorators(UseAuth(), Role(roles));
}
