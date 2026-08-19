import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';

@ArgsType()
export class PromotePartArgs {
  @Field(() => ObjectIdScalar)
  partId: Types.ObjectId;

  @Field(() => ServicePromotionPlanEnum)
  plan: ServicePromotionPlanEnum;
}
