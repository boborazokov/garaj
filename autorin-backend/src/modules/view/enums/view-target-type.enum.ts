import { registerEnumType } from '@nestjs/graphql';

export enum ViewTargetTypeEnum {
  PART = 'PART',
  USER = 'USER',
  WORKSHOP = 'WORKSHOP',
}

registerEnumType(ViewTargetTypeEnum, {
  name: 'ViewTargetTypeEnum',
});
