import { Field, InputType } from '@nestjs/graphql';

export const PAGE_DEFAULT = 1;
export const LIMIT_DEFAULT = 10;
export const PAGINATION_DEFAULT: PaginationInput = {
  page: PAGE_DEFAULT,
  limit: LIMIT_DEFAULT,
};

@InputType()
export class PaginationInput {
  @Field({ nullable: true, defaultValue: PAGE_DEFAULT })
  page: number;

  @Field({ nullable: true, defaultValue: LIMIT_DEFAULT })
  limit: number;
}
