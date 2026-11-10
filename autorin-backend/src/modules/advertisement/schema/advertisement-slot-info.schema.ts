import { Field, Int, ObjectType } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';

@ObjectType()
export class AdvertisementSlotInfo {
  @Field(() => CategoryTypeEnum)
  placement: CategoryTypeEnum;

  @Field(() => Int)
  activeCount: number;

  @Field(() => Int)
  maxSlots: number;

  @Field(() => Int)
  queueLength: number;

  @Field()
  hasFreeSlot: boolean;
}
