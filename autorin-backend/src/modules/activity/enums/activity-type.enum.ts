import { registerEnumType } from '@nestjs/graphql';

export enum ActivityTypeEnum {
  PRODUCT_VIEWED = 'PRODUCT_VIEWED',
  PRODUCT_OPENED = 'PRODUCT_OPENED',
  FAVORITE_ADDED = 'FAVORITE_ADDED',
  CHAT_OPENED = 'CHAT_OPENED',
  SEARCH_QUERY = 'SEARCH_QUERY',
  ORDER_OPENED = 'ORDER_OPENED',
}

registerEnumType(ActivityTypeEnum, { name: 'ActivityTypeEnum' });
