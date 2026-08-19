import { Field, InputType } from '@nestjs/graphql';
import { IsOptional } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@InputType()
export class CreateConversationInput {
  @Field(() => ObjectIdScalar)
  recipientId: Types.ObjectId;

  /** Optional: scope the chat to a specific Part listing. */
  @Field(() => ObjectIdScalar, { nullable: true })
  @IsOptional()
  partId?: Types.ObjectId;
}
