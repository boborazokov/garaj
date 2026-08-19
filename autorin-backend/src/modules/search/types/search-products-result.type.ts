import { Field, ObjectType } from '@nestjs/graphql';
import { Part } from 'src/modules/part/schema';

@ObjectType()
export class SearchProductsResult {
  @Field(() => [Part])
  payload: Part[];

  @Field()
  total: number;

  @Field()
  limit: number;

  @Field()
  offset: number;

  @Field()
  processingTimeMs: number;
}
