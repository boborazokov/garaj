import { Field, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { CurrencyEnum } from 'src/shared/enums';
import {
  PromotionPaymentStatusEnum,
  PromotionTargetTypeEnum,
} from '../enums';

@ObjectType()
@Schema({ timestamps: true, collection: COLLECTIONS.PROMOTION_PAYMENTS })
export class PromotionPayment {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    required: true,
    index: true,
  })
  user: Types.ObjectId;

  @Field(() => PromotionTargetTypeEnum)
  @Prop({
    type: String,
    enum: Object.values(PromotionTargetTypeEnum),
    required: true,
    index: true,
  })
  targetType: PromotionTargetTypeEnum;

  @Field(() => ObjectIdScalar)
  @Prop({ type: Types.ObjectId, required: true, index: true })
  targetId: Types.ObjectId;

  @Field(() => ServicePromotionPlanEnum)
  @Prop({
    type: String,
    enum: Object.keys(ServicePromotionPlanEnum),
    required: true,
  })
  plan: ServicePromotionPlanEnum;

  @Field(() => Int)
  @Prop({ required: true, min: 0 })
  amount: number;

  @Field(() => CurrencyEnum)
  @Prop({
    type: String,
    enum: Object.values(CurrencyEnum),
    default: CurrencyEnum.UZS,
  })
  currency: CurrencyEnum;

  @Field(() => PromotionPaymentStatusEnum)
  @Prop({
    type: String,
    enum: Object.values(PromotionPaymentStatusEnum),
    default: PromotionPaymentStatusEnum.PENDING,
    index: true,
  })
  status: PromotionPaymentStatusEnum;

  /** Gateway id once Payme/Click is connected; INTERNAL until then. */
  @Field()
  @Prop({ default: 'INTERNAL', index: true })
  provider: string;

  @Field(() => String, { nullable: true })
  @Prop({ type: String, default: null, index: true })
  providerRef?: string | null;

  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null })
  paidAt?: Date | null;

  /** Set only after the listing was successfully boosted. */
  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null })
  promotedAt?: Date | null;

  @Field(() => String, { nullable: true })
  @Prop({ type: String, default: null })
  failureReason?: string | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}

@ObjectType()
export class PromotionPlanPrice {
  @Field(() => ServicePromotionPlanEnum)
  plan: ServicePromotionPlanEnum;

  @Field(() => Int)
  amount: number;

  @Field(() => CurrencyEnum)
  currency: CurrencyEnum;

  @Field(() => Int)
  days: number;

  @Field(() => Int)
  priority: number;

  @Field(() => Int, { nullable: true })
  discountPercent?: number | null;
}
