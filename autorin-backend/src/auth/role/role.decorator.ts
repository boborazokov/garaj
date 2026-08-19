import { UserRoleEnum } from 'src/modules/user/enums';
import { ROLE_METADATA } from './role.watermark';

export function Role(roles: UserRoleEnum[]): MethodDecorator {
  return (target: any, propertyKey: string) => {
    Reflect.defineMetadata(ROLE_METADATA, roles, target, propertyKey);
  };
}
