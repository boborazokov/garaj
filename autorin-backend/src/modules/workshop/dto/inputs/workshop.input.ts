import { Field, Float, InputType } from '@nestjs/graphql';
import { GeolocationInput } from 'src/shared/inputs/geolocation.input';
import {
  WorkshopDayScheduleInput,
  WorkshopServicePriceInput,
} from '../../schema/workshop-embedded.schema';

@InputType()
export class WorkshopInput {
  @Field()
  name: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  location?: string;

  @Field({ nullable: true })
  address?: string;

  @Field({ nullable: true })
  city?: string;

  @Field(() => GeolocationInput)
  geoLocation: GeolocationInput;

  @Field(() => Float, { nullable: true })
  serviceRadiusKm?: number;

  @Field(() => [String], { nullable: true })
  categoryIds?: string[];

  @Field(() => [WorkshopServicePriceInput], { nullable: true })
  servicePricing?: WorkshopServicePriceInput[];

  @Field(() => [WorkshopDayScheduleInput], { nullable: true })
  weeklySchedule?: WorkshopDayScheduleInput[];

  @Field()
  openFrom: Date;

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
}
