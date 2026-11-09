import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { PromotionTargetTypeEnum } from '../../enums';

/** Admin fallback when auto-promote after payment failed. */
@ArgsType()
export class AdminFulfillPromotionArgs {
  @Field(() => PromotionTargetTypeEnum)
  targetType: PromotionTargetTypeEnum;

  @Field(() => ObjectIdScalar)
  targetId: Types.ObjectId;

  @Field(() => ServicePromotionPlanEnum, { nullable: true })
  plan?: ServicePromotionPlanEnum;
}

@ArgsType()
export class AdminRetryPromotionPaymentArgs {
  @Field(() => ObjectIdScalar)
  paymentId: Types.ObjectId;
}
