import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { ServicePromotionPlanEnum } from '../../enums/service-promotion-plan.enum';

@ArgsType()
export class PromoteServiceArgs {
  @Field(() => ObjectIdScalar)
  serviceId: Types.ObjectId;

  @Field(() => ServicePromotionPlanEnum)
  plan: ServicePromotionPlanEnum;
}
