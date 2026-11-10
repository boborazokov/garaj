import { ArgsType, Field } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementPlanEnum } from '../../enums';

@ArgsType()
export class PurchaseAdvertisementArgs {
  @Field(() => CategoryTypeEnum)
  type: CategoryTypeEnum;

  @Field(() => AdvertisementPlanEnum)
  plan: AdvertisementPlanEnum;

  @Field()
  title: string;

  @Field()
  link: string;

  @Field()
  bannerImageUrl: string;
}
