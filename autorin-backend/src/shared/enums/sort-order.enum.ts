import { registerEnumType } from '@nestjs/graphql';

export enum SortOrderEnum {
  /** Promoted-in-region → promoted-global → newest. Default for marketplaces. */
  RECOMMENDED = 'RECOMMENDED',
  NEWEST = 'NEWEST',
  PRICE_ASC = 'PRICE_ASC',
  PRICE_DESC = 'PRICE_DESC',
}

registerEnumType(SortOrderEnum, { name: 'SortOrderEnum' });
