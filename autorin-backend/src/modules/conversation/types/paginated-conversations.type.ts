import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { ConversationView } from './conversation-summary.type';

@ObjectType()
export class PaginatedConversations extends PaginationResult {
  @Field(() => [ConversationView])
  payload: ConversationView[];
}
