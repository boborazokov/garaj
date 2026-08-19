import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { Advertisement } from '../schema';

@ObjectType()
export class PaginatedAdvertisements extends PaginationResult {
  @Field(() => [Advertisement])
  payload: Advertisement[];
}
