import { Field, Float, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { User } from 'src/modules/user/schema';
import { ServiceCategory } from 'src/modules/service-category/schema/service-category.schema';
import { ServicePromotionPlanEnum } from '../enums/service-promotion-plan.enum';
import {
  fromGeoJsonPoint,
  GEO_POINT_SCHEMA,
  GeoJsonPoint,
  GeoPoint,
} from 'src/shared/geo';

@ObjectType('Service')
@Schema({ timestamps: true })
export class AutoService {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ required: true, index: true })
  title: string;

  @Field()
  @Prop({ default: '' })
  description: string;

  @Field(() => ServiceCategory)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.SERVICE_CATEGORIES,
    required: true,
    index: true,
  })
  category: ServiceCategory | Types.ObjectId;

  @Field(() => GeoPoint)
  geoLocation: GeoPoint;

  @Prop({ type: GEO_POINT_SCHEMA })
  geo: GeoJsonPoint;

  @Field({ nullable: true })
  @Prop({ default: '' })
  address?: string;

  @Field(() => [String])
  @Prop({ type: [String], default: [] })
  images: string[];

  @Field()
  @Prop({ required: true })
  openFrom: Date;

  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null })
  openUntil?: Date | null;

  @Field({ nullable: true })
  @Prop({ default: '' })
  phone?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  telegram?: string;

  @Field()
  @Prop({ default: false, index: true })
  verified: boolean;

  @Field(() => [String])
  @Prop({ type: [String], default: [] })
  features: string[];

  @Field(() => Float)
  @Prop({ default: 0, min: 0, max: 5 })
  rating: number;

  @Field()
  @Prop({ default: 0, min: 0 })
  reviewCount: number;

  @Field()
  @Prop({ default: false, index: true })
  isEmergency: boolean;

  @Field(() => User)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, required: true, index: true })
  owner: User | Types.ObjectId;

  @Field(() => ItemStatusEnum)
  @Prop({
    type: String,
    enum: Object.keys(ItemStatusEnum),
    default: () => ItemStatusEnum.ACTIVE,
    index: true,
  })
  status: ItemStatusEnum;

  /** True while `promotedUntil > now`. Boosted listings sort above organic. */
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

  /** Denormalised sort key (plan weight). 0 = not boosted. */
  @Field()
  @Prop({ default: 0, index: true })
  promotionPriority: number;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}

/** Resolve GraphQL geo from stored GeoJSON. */
export function resolveServiceGeo(doc: AutoService & { geo?: GeoJsonPoint }): GeoPoint | null {
  return fromGeoJsonPoint(doc.geo);
}
