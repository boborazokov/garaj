import { registerEnumType } from '@nestjs/graphql';

export enum ViewTargetTypeEnum {
  PART = 'PART',
  USER = 'USER',
  WORKSHOP = 'WORKSHOP',
  ORDER = 'ORDER',
}

registerEnumType(ViewTargetTypeEnum, {
  name: 'ViewTargetTypeEnum',
});
