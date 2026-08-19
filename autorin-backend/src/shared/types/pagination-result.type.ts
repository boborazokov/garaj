import { Field, Int, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class PaginationResult {
  @Field()
  totalDocs: number;

  @Field()
  limit: number;

  @Field()
  hasPrevPage: boolean;

  @Field()
  hasNextPage: boolean;

  @Field(() => Int, { nullable: true })
  page?: number;

  @Field()
  totalPages: number;

  @Field(() => Int, { nullable: true })
  prevPage?: number | null;

  @Field(() => Int, { nullable: true })
  nextPage?: number | null;
}
