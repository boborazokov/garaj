import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { WorkshopReview } from '../schema/workshop-review.schema';

@ObjectType()
export class PaginatedWorkshopReviews extends PaginationResult {
  @Field(() => [WorkshopReview])
  payload: WorkshopReview[];
}
