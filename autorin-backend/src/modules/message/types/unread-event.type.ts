import { Field, ObjectType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ObjectType()
export class UnreadCountEvent {
  @Field(() => ObjectIdScalar)
  conversationId: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;

  @Field()
  unread: number;
}
