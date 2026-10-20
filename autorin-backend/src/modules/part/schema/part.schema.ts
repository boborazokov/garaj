import { Field, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { Category } from 'src/modules/category/schema';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { User } from 'src/modules/user/schema';
import { CurrencyEnum } from 'src/shared/enums';
import { DeliveryConditionEnum } from '../enums';
import { GEO_POINT_SCHEMA, GeoJsonPoint, GeoPoint } from 'src/shared/geo';

@ObjectType()
@Schema({ timestamps: true })
export class Part {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ index: true })
  name: string;

  @Field()
  @Prop()
  description: string;

  @Field()
  @Prop({ default: false })
  isNegotiable: boolean;

  @Field(() => DeliveryConditionEnum)
  @Prop({ default: false })
  deliveryCondition: DeliveryConditionEnum;

  @Field()
  @Prop({ default: false })
  isNew: boolean;

  @Field()
  @Prop({ default: 0, min: 0, index: true })
  price: number;

  @Field()
  @Prop({ default: 0, min: 0 })
  quantity: number;

  @Field(() => Int)
  @Prop({ default: 0, min: 0 })
  viewsCount: number;

  @Field(() => CurrencyEnum)
  @Prop({ type: String, enum: Object.keys(CurrencyEnum), index: true })
  currency: CurrencyEnum;

  @Field(() => [String], { nullable: true })
  @Prop({ default: [], type: [String] })
  images?: string[];

  @Field(() => User)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS })
  seller: User | Types.ObjectId;

  @Field(() => ItemStatusEnum)
  @Prop({
    type: String,
    enum: Object.keys(ItemStatusEnum),
    default: () => ItemStatusEnum.ACTIVE,
  })
  status: ItemStatusEnum;

  @Field({ nullable: true })
  @Prop({ type: Date })
  activeUntil?: Date;

  @Field(() => Category)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.CATEGORIES, index: true })
  category: Types.ObjectId | Category;

  /** Optional brand (BRAND-typed Category id). */
  @Field(() => Category, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.CATEGORIES, default: null, index: true })
  brand?: Types.ObjectId | Category | null;

  /** Optional model (MODEL-typed Category id). */
  @Field(() => Category, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.CATEGORIES, default: null, index: true })
  carModel?: Types.ObjectId | Category | null;

  /** Free-form address string (e.g. "Tashkent, Yunusabad"). */
  @Field({ nullable: true })
  @Prop({ default: '' })
  location?: string;

  /** Region/city slug used for "promoted-in-region first" sorting. */
  @Field({ nullable: true })
  @Prop({ default: '', index: true })
  region?: string;

  @Field(() => GeoPoint, { nullable: true })
  geoLocation?: GeoPoint | null;

  @Prop({ type: GEO_POINT_SCHEMA, required: false })
  geo?: GeoJsonPoint;

  /** True while `promotedUntil > now`. Promoted items float to the top. */
  @Field()
  @Prop({ default: false, index: true })
  isPromoted: boolean;

  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null, index: true })
  promotedUntil?: Date | null;

  @Field(() => ServicePromotionPlanEnum, { nullable: true })
  @Prop({
    type: String,
    enum: Object.keys(ServicePromotionPlanEnum),
    default: null,
  })
  promotionPlan?: ServicePromotionPlanEnum | null;

  @Field()
  @Prop({ default: 0, index: true })
  promotionPriority: number;

  @Field()
  @Prop({ default: Date.now })
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;

  @Field(() => String, { nullable: true })
  @Prop({ type: String, default: null })
  moderationNote?: string | null;

  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null })
  moderatedAt?: Date | null;

  @Field(() => User, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, default: null })
  moderatedBy?: Types.ObjectId | User | null;

  /** Resolved per viewer via [PartFieldsResolver.isFavorite]. */
  @Field(() => Boolean)
  isFavorite?: boolean;
}
