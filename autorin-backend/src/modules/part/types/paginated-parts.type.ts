import { Field, ObjectType } from '@nestjs/graphql';
import { Part } from '../schema';
import { PaginationResult } from 'src/shared/types';

@ObjectType()
export class PaginatedParts extends PaginationResult {
  @Field(() => [Part])
  payload: Part[];
}
