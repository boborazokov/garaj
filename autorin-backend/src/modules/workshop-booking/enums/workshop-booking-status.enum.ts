import { registerEnumType } from '@nestjs/graphql';

export enum WorkshopBookingStatusEnum {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  CANCELLED = 'CANCELLED',
  COMPLETED = 'COMPLETED',
}

registerEnumType(WorkshopBookingStatusEnum, {
  name: 'WorkshopBookingStatusEnum',
});
