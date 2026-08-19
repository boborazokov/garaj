import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { AutoService } from '../schema/service.schema';

@ObjectType()
export class PaginatedServices extends PaginationResult {
  @Field(() => [AutoService])
  payload: AutoService[];
}
