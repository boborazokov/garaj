import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { PromotionTargetTypeEnum } from '../../enums';

@ArgsType()
export class PurchasePromotionArgs {
  @Field(() => PromotionTargetTypeEnum)
  targetType: PromotionTargetTypeEnum;

  @Field(() => ObjectIdScalar)
  targetId: Types.ObjectId;

  @Field(() => ServicePromotionPlanEnum)
  plan: ServicePromotionPlanEnum;
}
