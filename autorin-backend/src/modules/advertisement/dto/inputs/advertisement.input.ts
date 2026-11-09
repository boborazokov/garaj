import { Field, InputType } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementStatusEnum } from '../../enums';

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

  @Field(() => Date, { nullable: true })
  startsAt?: Date | null;

  @Field(() => Date, { nullable: true })
  endsAt?: Date | null;

  /** Admin may set ACTIVE or PAUSED. EXPIRED is date-derived. */
  @Field(() => AdvertisementStatusEnum, { nullable: true })
  status?: AdvertisementStatusEnum;

  @Field({ nullable: true })
  isFree?: boolean;
}
