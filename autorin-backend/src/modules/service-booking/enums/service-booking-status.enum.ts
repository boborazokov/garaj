import { registerEnumType } from '@nestjs/graphql';

export enum ServiceBookingStatusEnum {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  CANCELLED = 'CANCELLED',
  COMPLETED = 'COMPLETED',
}

registerEnumType(ServiceBookingStatusEnum, {
  name: 'ServiceBookingStatusEnum',
});
