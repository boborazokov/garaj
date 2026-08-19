import { registerEnumType } from '@nestjs/graphql';

export enum UserRoleEnum {
  ADMIN = 'ADMIN',
  MODERATOR = 'MODERATOR',
  USER = 'USER',
}

registerEnumType(UserRoleEnum, { name: 'UserRoleEnum' });
