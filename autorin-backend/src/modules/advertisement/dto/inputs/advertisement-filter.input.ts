import { Field, InputType } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';

@InputType()
export class AdvertisementFilterInput {
  @Field(() => CategoryTypeEnum, { nullable: true })
  type?: CategoryTypeEnum;

  @Field({ nullable: true })
  title?: string;
}
