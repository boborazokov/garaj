import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { Message } from '../schema';

const messageSchema = SchemaFactory.createForClass(Message);

// Paginate the message stream of a conversation in O(log n).
// The compound index supports cursor pagination (createdAt + _id tiebreak).
messageSchema.index({ conversation: 1, createdAt: -1, _id: -1 });

// Lookups for "messages I haven't read yet in this conversation".
messageSchema.index({ conversation: 1, readBy: 1 });

export const MessageModel: ModelDefinition = {
  name: COLLECTIONS.MESSAGES,
  schema: messageSchema,
};
