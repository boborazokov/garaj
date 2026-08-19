import { Field, ObjectType } from '@nestjs/graphql';
import { Workshop } from '../schema';
import { PaginationResult } from 'src/shared/types';

@ObjectType()
export class PaginatedWorkshops extends PaginationResult {
  @Field(() => [Workshop])
  payload: Workshop[];
}
