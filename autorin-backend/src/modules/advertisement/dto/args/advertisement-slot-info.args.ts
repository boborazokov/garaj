import { ArgsType, Field } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';

@ArgsType()
export class AdvertisementSlotInfoArgs {
  @Field(() => CategoryTypeEnum)
  type: CategoryTypeEnum;
}
