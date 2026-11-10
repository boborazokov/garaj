import { Field, Int, ObjectType } from '@nestjs/graphql';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { CurrencyEnum } from 'src/shared/enums/currency.enum';
import { AdvertisementPlanEnum } from '../enums/advertisement-plan.enum';

@ObjectType()
export class AdvertisementPlanPrice {
  @Field(() => CategoryTypeEnum)
  placement: CategoryTypeEnum;

  @Field(() => AdvertisementPlanEnum)
  plan: AdvertisementPlanEnum;

  @Field(() => Int)
  amount: number;

  @Field(() => CurrencyEnum)
  currency: CurrencyEnum;

  @Field(() => Int)
  days: number;

  @Field(() => Int)
  priority: number;
}
