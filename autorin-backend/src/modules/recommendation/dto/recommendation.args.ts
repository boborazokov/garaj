import { ArgsType, Field, Int } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class RecommendationListArgs {
  @Field(() => Int, { nullable: true, defaultValue: 12 })
  limit?: number;

  @Field({ nullable: true })
  city?: string;
}

@ArgsType()
export class SimilarProductsArgs {
  @Field(() => ObjectIdScalar)
  productId: Types.ObjectId;

  @Field(() => Int, { nullable: true, defaultValue: 10 })
  limit?: number;
}

@ArgsType()
export class NearbyProductsArgs extends RecommendationListArgs {
  @Field({ nullable: true })
  region?: string;
}
