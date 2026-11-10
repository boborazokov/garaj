import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { PromotionTargetTypeEnum } from '../../enums';

@ArgsType()
export class CancelPromotionArgs {
  @Field(() => PromotionTargetTypeEnum)
  targetType: PromotionTargetTypeEnum;

  @Field(() => ObjectIdScalar)
  targetId: Types.ObjectId;
}
