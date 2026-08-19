import { Field, InputType } from '@nestjs/graphql';
import { MaxLength } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { MESSAGE_TEXT_MAX } from '../../schema/message.schema';

@InputType()
export class UpdateMessageInput {
  @Field(() => ObjectIdScalar)
  messageId: Types.ObjectId;

  @Field()
  @MaxLength(MESSAGE_TEXT_MAX)
  text: string;
}
