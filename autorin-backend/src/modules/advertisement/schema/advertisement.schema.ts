import { Field, Float, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementPlanEnum, AdvertisementStatusEnum } from '../enums';

@ObjectType()
@Schema({ timestamps: true })
export class Advertisement {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ required: true })
  type: CategoryTypeEnum;

  @Field()
  @Prop({ required: true })
  bannerImageUrl: string;

  @Field()
  @Prop({ required: true })
  title: string;

  @Field()
  @Prop({ required: true })
  link: string;

  /** Campaign window start (UTC). Null = no start limit. */
  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null, index: true })
  startsAt?: Date | null;

  /** Campaign window end (UTC). Null = no end limit. */
  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null, index: true })
  endsAt?: Date | null;

  /**
   * Stored lifecycle flag. `EXPIRED` is also derived when `endsAt` is past —
   * GraphQL always returns the effective status via the service helper.
   */
  @Field(() => AdvertisementStatusEnum)
  @Prop({
    type: String,
    enum: Object.keys(AdvertisementStatusEnum),
    default: AdvertisementStatusEnum.ACTIVE,
    index: true,
  })
  status: AdvertisementStatusEnum;

  @Field(() => Int)
  @Prop({ type: Number, default: 0, min: 0 })
  impressionCount: number;

  @Field(() => Int)
  @Prop({ type: Number, default: 0, min: 0 })
  clickCount: number;

  /** CTR percent (clicks / impressions * 100). Computed, not stored. */
  @Field(() => Float)
  ctr: number;

  /**
   * Internal / complimentary placement (Jizzax pilot banners). Not billed;
   * still tracked for impressions/clicks.
   */
  @Field()
  @Prop({ type: Boolean, default: false })
  isFree: boolean;

  /** Buyer who purchased from the app. Null for admin/complimentary. */
  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: 'User', default: null, index: true })
  ownerId?: Types.ObjectId | null;

  /** Paid duration tier (null for legacy / free admin banners). */
  @Field(() => AdvertisementPlanEnum, { nullable: true })
  @Prop({
    type: String,
    enum: Object.keys(AdvertisementPlanEnum),
    default: null,
  })
  plan?: AdvertisementPlanEnum | null;

  /** UZS charged at purchase (0 for free / admin). */
  @Field(() => Int)
  @Prop({ type: Number, default: 0, min: 0 })
  amountPaid: number;

  /**
   * Queue order when status is QUEUED (1 = next up). 0 when live / not queued.
   */
  @Field(() => Int)
  @Prop({ type: Number, default: 0, min: 0, index: true })
  queuePosition: number;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
