import { registerEnumType } from '@nestjs/graphql';

export enum ServiceBookingPaymentStatusEnum {
  UNPAID = 'UNPAID',
  PAID = 'PAID',
  REFUNDED = 'REFUNDED',
  FAILED = 'FAILED',
}

registerEnumType(ServiceBookingPaymentStatusEnum, {
  name: 'ServiceBookingPaymentStatusEnum',
});
