import { Field, Float, InputType } from '@nestjs/graphql';
import { GeolocationInput } from 'src/shared/inputs/geolocation.input';
import {
  WorkshopDayScheduleInput,
  WorkshopServicePriceInput,
} from '../../schema/workshop-embedded.schema';

@InputType()
export class WorkshopUpdateInput {
  @Field({ nullable: true })
  name?: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  location?: string;

  @Field({ nullable: true })
  address?: string;

  @Field({ nullable: true })
  city?: string;

  @Field(() => GeolocationInput, { nullable: true })
  geoLocation?: GeolocationInput;

  @Field(() => Float, { nullable: true })
  serviceRadiusKm?: number;

  @Field(() => [String], { nullable: true })
  categoryIds?: string[];

  @Field(() => [WorkshopServicePriceInput], { nullable: true })
  servicePricing?: WorkshopServicePriceInput[];

  @Field(() => [WorkshopDayScheduleInput], { nullable: true })
  weeklySchedule?: WorkshopDayScheduleInput[];

  @Field({ nullable: true })
  openFrom?: Date;

  @Field({ nullable: true })
  openUntil?: Date;

  @Field({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  telegram?: string;

  @Field({ nullable: true })
  fastResponse?: boolean;

  @Field({ nullable: true })
  open24Hours?: boolean;

  @Field({ nullable: true })
  responseTimeMinutes?: number;

  /** Gallery URLs already uploaded via REST (MinIO paths or full URLs). */
  @Field(() => [String], { nullable: true })
  gallery?: string[];
}
