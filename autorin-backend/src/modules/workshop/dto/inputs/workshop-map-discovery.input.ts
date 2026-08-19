import { ArgsType, Field, Float, InputType, Int } from '@nestjs/graphql';

@InputType()
export class MapBoundsInput {
  @Field(() => Float)
  southWestLat: number;

  @Field(() => Float)
  southWestLng: number;

  @Field(() => Float)
  northEastLat: number;

  @Field(() => Float)
  northEastLng: number;
}

@InputType()
export class WorkshopFiltersInput {
  @Field(() => Boolean, { nullable: true })
  openNow?: boolean;

  @Field(() => Boolean, { nullable: true })
  verified?: boolean;

  @Field(() => Boolean, { nullable: true })
  premium?: boolean;

  @Field(() => Boolean, { nullable: true })
  topRated?: boolean;

  @Field(() => Boolean, { nullable: true })
  emergencyOnly?: boolean;

  @Field(() => [String], { nullable: true })
  services?: string[];

  @Field(() => [String], { nullable: true })
  brands?: string[];

  @Field(() => Float, { nullable: true })
  minRating?: number;

  @Field({ nullable: true })
  city?: string;

  @Field(() => Boolean, { nullable: true })
  hasPickupService?: boolean;

  @Field(() => Boolean, { nullable: true })
  open24Hours?: boolean;
}

@ArgsType()
export class WorkshopMapDiscoveryArgs {
  @Field(() => Float)
  latitude: number;

  @Field(() => Float)
  longitude: number;

  @Field(() => Float, { nullable: true, defaultValue: 25 })
  radiusKm?: number;

  @Field(() => MapBoundsInput, { nullable: true })
  bounds?: MapBoundsInput;

  @Field(() => WorkshopFiltersInput, { nullable: true })
  filters?: WorkshopFiltersInput;

  @Field(() => Int, { nullable: true, defaultValue: 120 })
  limit?: number;
}

@ArgsType()
export class NearbyLatLngArgs {
  @Field(() => Float)
  lat: number;

  @Field(() => Float)
  lng: number;

  @Field(() => Float, { nullable: true, defaultValue: 15 })
  radius?: number;

  @Field(() => Int, { nullable: true, defaultValue: 40 })
  limit?: number;
}
