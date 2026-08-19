import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { User } from '../schema';

@ObjectType()
export class PaginatedUsers extends PaginationResult {
  @Field(() => [User])
  payload: User[];
}
