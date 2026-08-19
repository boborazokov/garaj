import { registerEnumType } from '@nestjs/graphql';

export enum OrderUrgencyEnum {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  URGENT = 'URGENT',
}

registerEnumType(OrderUrgencyEnum, { name: 'OrderUrgencyEnum' });
