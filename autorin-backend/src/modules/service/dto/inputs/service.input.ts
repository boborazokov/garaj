import { Field, Float, InputType } from '@nestjs/graphql';
import { GeolocationInput } from 'src/shared/inputs/geolocation.input';

@InputType()
export class ServiceInput {
  @Field()
  title: string;

  @Field({ nullable: true })
  description?: string;

  @Field()
  categoryId: string;

  @Field(() => GeolocationInput)
  geoLocation: GeolocationInput;

  @Field({ nullable: true })
  address?: string;

  @Field()
  openFrom: Date;

  @Field({ nullable: true })
  openUntil?: Date;

  @Field({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  telegram?: string;

  @Field(() => [String], { nullable: true })
  features?: string[];

  @Field({ nullable: true })
  isEmergency?: boolean;
}

@InputType()
export class ServiceFilterInput {
  @Field({ nullable: true })
  categoryId?: string;

  @Field({ nullable: true })
  verified?: boolean;

  @Field({ nullable: true })
  isEmergency?: boolean;

  @Field({ nullable: true })
  openNow?: boolean;
}
