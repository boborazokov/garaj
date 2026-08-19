import { Field, InputType } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';

@InputType()
export class AdvertisementInput {
  @Field(() => CategoryTypeEnum)
  type: CategoryTypeEnum;

  @Field()
  bannerImageUrl: string;

  @Field()
  title: string;

  @Field()
  link: string;
}
