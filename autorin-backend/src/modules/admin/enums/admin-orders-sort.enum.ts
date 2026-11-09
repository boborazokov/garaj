import { registerEnumType } from '@nestjs/graphql';

export enum AdminOrdersSortEnum {
  NEWEST = 'NEWEST',
  OLDEST = 'OLDEST',
  BUDGET_ASC = 'BUDGET_ASC',
  BUDGET_DESC = 'BUDGET_DESC',
  RECOMMENDED = 'RECOMMENDED',
}

registerEnumType(AdminOrdersSortEnum, {
  name: 'AdminOrdersSortEnum',
});
