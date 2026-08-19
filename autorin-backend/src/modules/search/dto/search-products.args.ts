import { ArgsType, Field, Float, Int } from '@nestjs/graphql';

@ArgsType()
export class SearchProductsArgs {
  @Field({ nullable: true })
  query?: string;

  @Field({ nullable: true })
  category?: string;

  @Field({ nullable: true })
  city?: string;

  @Field(() => Float, { nullable: true })
  minPrice?: number;

  @Field(() => Float, { nullable: true })
  maxPrice?: number;

  @Field(() => Int, { nullable: true, defaultValue: 20 })
  limit?: number;

  @Field(() => Int, { nullable: true, defaultValue: 0 })
  offset?: number;
}
