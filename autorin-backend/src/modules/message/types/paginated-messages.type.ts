import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { Message } from '../schema';

@ObjectType()
export class PaginatedMessages extends PaginationResult {
  @Field(() => [Message])
  payload: Message[];
}
