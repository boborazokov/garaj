import { Field, InputType, Int } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementPlanEnum, AdvertisementStatusEnum } from '../../enums';

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

  /** Tariff tier for admin create/edit (DAY / WEEK / MONTH / QUARTER). */
  @Field(() => AdvertisementPlanEnum, { nullable: true })
  plan?: AdvertisementPlanEnum | null;

  /** Optional override; if omitted and plan set, server fills from tariff matrix. */
  @Field(() => Int, { nullable: true })
  amountPaid?: number | null;
}
