import { Field, ObjectType } from '@nestjs/graphql';
import { Conversation } from '../schema';

/**
 * Conversation as exposed to the inbox screen.
 *
 * Adds a viewer-scoped `unread` field so the client doesn't have to
 * compute it from the raw counter map (and we don't have to expose
 * other users' counters at all).
 */
@ObjectType()
export class ConversationView extends Conversation {
  @Field({ defaultValue: 0 })
  unread: number;
}
