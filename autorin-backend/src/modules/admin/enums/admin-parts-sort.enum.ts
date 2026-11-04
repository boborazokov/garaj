import { registerEnumType } from '@nestjs/graphql';

export enum AdminPartsSortEnum {
  NEWEST = 'NEWEST',
  OLDEST = 'OLDEST',
  VIEWS = 'VIEWS',
  PRICE_ASC = 'PRICE_ASC',
  PRICE_DESC = 'PRICE_DESC',
  RECOMMENDED = 'RECOMMENDED',
}

registerEnumType(AdminPartsSortEnum, {
  name: 'AdminPartsSortEnum',
});
