import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class GeolocationInput {
  @Field()
  latitude: number;

  @Field()
  longitude: number;
}
