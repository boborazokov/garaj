import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { Conversation } from '../schema';

const conversationSchema = SchemaFactory.createForClass(Conversation);

// Inbox lookups: every participant page-paginated by recent activity.
conversationSchema.index({ participants: 1, lastMessageAt: -1 });

// Idempotent findOrCreate by (participants, part).
conversationSchema.index({ participants: 1, part: 1 });

// Global "recent" lookups (admin tooling).
conversationSchema.index({ lastMessageAt: -1 });

export const ConversationModel: ModelDefinition = {
  name: COLLECTIONS.CONVERSATIONS,
  schema: conversationSchema,
};
