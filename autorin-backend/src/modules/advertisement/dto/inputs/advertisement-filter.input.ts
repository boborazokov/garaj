import { Field, InputType } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementStatusEnum } from '../../enums';

@InputType()
export class AdvertisementFilterInput {
  @Field(() => CategoryTypeEnum, { nullable: true })
  type?: CategoryTypeEnum;

  @Field({ nullable: true })
  title?: string;

  @Field(() => AdvertisementStatusEnum, { nullable: true })
  status?: AdvertisementStatusEnum;

  @Field({ nullable: true })
  isFree?: boolean;
}
