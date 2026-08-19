import { registerEnumType } from '@nestjs/graphql';

export enum OrderStatusEnum {
  /** Visible to sellers, can be matched / contacted. */
  ACTIVE = 'ACTIVE',
  /** User found what they wanted. Hidden from public listings. */
  CLOSED = 'CLOSED',
  /** Cancelled by user / moderation. */
  CANCELLED = 'CANCELLED',
}

registerEnumType(OrderStatusEnum, { name: 'OrderStatusEnum' });
