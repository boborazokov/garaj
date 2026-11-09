import { registerEnumType } from '@nestjs/graphql';

export enum AdminWorkshopsSortEnum {
  NEWEST = 'NEWEST',
  OLDEST = 'OLDEST',
  VIEWS = 'VIEWS',
  RECOMMENDED = 'RECOMMENDED',
}

registerEnumType(AdminWorkshopsSortEnum, {
  name: 'AdminWorkshopsSortEnum',
});
