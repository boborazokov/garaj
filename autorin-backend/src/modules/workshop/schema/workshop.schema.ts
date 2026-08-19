import { Field, Float, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { User } from 'src/modules/user/schema';
import { WorkshopCategory } from 'src/modules/workshop-category/schema/workshop-category.schema';
import {
  fromGeoJsonPoint,
  GEO_POINT_SCHEMA,
  GeoJsonPoint,
  GeoPoint,
} from 'src/shared/geo';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import {
  WorkshopDaySchedule,
  WorkshopServicePrice,
} from './workshop-embedded.schema';

@ObjectType()
@Schema({ timestamps: true })
export class Workshop {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ required: true, index: true })
  name: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  description?: string;

  /** Legacy display string; prefer address + city. */
  @Field({ nullable: true })
  @Prop({ default: '' })
  location?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  address?: string;

  @Field({ nullable: true })
  @Prop({ default: '', index: true })
  city?: string;

  @Field(() => GeoPoint)
  geoLocation: GeoPoint;

  @Prop({ type: GEO_POINT_SCHEMA })
  geo?: GeoJsonPoint;

  /** GeoJSON Point for map queries — synced with `geo`. Field name avoids clash with string `location`. */
  @Prop({ type: GEO_POINT_SCHEMA })
  mapLocation?: GeoJsonPoint;

  @Field(() => Float, { nullable: true })
  @Prop({ default: 15, min: 1, max: 100 })
  serviceRadiusKm?: number;

  @Field({ nullable: true })
  @Prop({ default: '' })
  coverImage?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  logo?: string;

  @Field(() => [String])
  @Prop({ type: [String], default: [] })
  gallery: string[];

  @Field(() => [String], { nullable: true })
  @Prop({ type: [String], default: [] })
  images?: string[];

  @Field(() => [WorkshopCategory])
  categories: WorkshopCategory[];

  @Prop({
    type: [{ type: Types.ObjectId, ref: COLLECTIONS.WORKSHOP_CATEGORIES }],
    default: [],
    index: true,
  })
  categoryIds: Types.ObjectId[];

  @Field(() => [WorkshopServicePrice])
  @Prop({ type: [Object], default: [] })
  servicePricing: WorkshopServicePrice[];

  @Field(() => [WorkshopDaySchedule])
  @Prop({ type: [Object], default: [] })
  weeklySchedule: WorkshopDaySchedule[];

  @Field()
  @Prop({ required: true })
  openFrom: Date;

  @Field({ nullable: true })
  @Prop({ type: Date, default: null })
  openUntil?: Date;

  @Field({ nullable: true })
  @Prop({ default: '' })
  phone?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  telegram?: string;

  @Field()
  @Prop({ default: false, index: true })
  verified: boolean;

  @Field()
  @Prop({ default: false, index: true })
  premium: boolean;

  /** True while `promotedUntil > now`. Boosted workshops sort above organic. */
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
  @Prop({ default: false })
  hasPickupService: boolean;

  @Field()
  @Prop({ default: false })
  open24Hours: boolean;

  @Field()
  @Prop({ default: false, index: true })
  isEmergency: boolean;

  @Field(() => [String])
  @Prop({ type: [String], default: [] })
  supportedCarBrands: string[];

  @Field(() => Float)
  @Prop({ default: 0, min: 0, max: 5 })
  rating: number;

  @Field()
  @Prop({ default: 0, min: 0 })
  reviewCount: number;

  @Field()
  @Prop({ default: false })
  fastResponse: boolean;

  @Field(() => Int, { nullable: true })
  @Prop({ type: Number, default: null })
  responseTimeMinutes?: number | null;

  @Field()
  @Prop({ default: 0 })
  bookingCount: number;

  @Field()
  @Prop({ default: 0 })
  viewCount: number;

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

  @Field({ nullable: true })
  @Prop({ type: Date, default: null })
  activeUntil?: Date;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;

  /** Computed on read — open right now from weeklySchedule. */
  @Field()
  isOpenNow: boolean;
}

export function resolveWorkshopGeo(
  doc: Workshop & { geo?: GeoJsonPoint; mapLocation?: GeoJsonPoint },
): GeoPoint | null {
  return fromGeoJsonPoint(doc.geo) ?? fromGeoJsonPoint(doc.mapLocation);
}
