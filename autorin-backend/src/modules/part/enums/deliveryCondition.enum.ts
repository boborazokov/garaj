import { registerEnumType } from '@nestjs/graphql';

export enum DeliveryConditionEnum {
  INCLUDED = 'INCLUDED',
  NOT_INCLUDED = 'NOT_INCLUDED',
  UNDER_CONTRACT = 'UNDER_CONTRACT',
}

registerEnumType(DeliveryConditionEnum, {
  name: 'DeliveryConditionEnum',
});
