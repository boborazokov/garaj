import { registerEnumType } from '@nestjs/graphql';

/** Listing kinds that can be boosted to the top of discovery feeds. */
export enum PromotionTargetTypeEnum {
  PART = 'PART',
  ORDER = 'ORDER',
  SERVICE = 'SERVICE',
  WORKSHOP = 'WORKSHOP',
}

registerEnumType(PromotionTargetTypeEnum, {
  name: 'PromotionTargetTypeEnum',
});
