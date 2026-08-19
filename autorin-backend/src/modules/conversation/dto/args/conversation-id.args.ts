import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class ConversationIdArgs {
  @Field(() => ObjectIdScalar)
  conversationId: Types.ObjectId;
}
