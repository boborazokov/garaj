import { registerEnumType } from '@nestjs/graphql';

export enum PromotionPaymentStatusEnum {
  PENDING = 'PENDING',
  PAID = 'PAID',
  FAILED = 'FAILED',
  CANCELLED = 'CANCELLED',
}

registerEnumType(PromotionPaymentStatusEnum, {
  name: 'PromotionPaymentStatusEnum',
});
