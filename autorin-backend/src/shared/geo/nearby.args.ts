import { ArgsType, Field, Float, Int } from '@nestjs/graphql';

@ArgsType()
export class NearbyArgs {
  @Field(() => Float)
  latitude: number;

  @Field(() => Float)
  longitude: number;

  @Field(() => Float, {
    nullable: true,
    defaultValue: 15,
    description: 'Search radius in kilometres',
  })
  radiusKm?: number;

  @Field(() => Int, { nullable: true, defaultValue: 40 })
  limit?: number;
}
