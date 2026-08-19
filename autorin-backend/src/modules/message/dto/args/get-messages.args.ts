import { ArgsType, Field } from '@nestjs/graphql';
import { IsOptional } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { PaginationInput } from 'src/shared/inputs';

@ArgsType()
export class GetMessagesArgs {
  @Field(() => ObjectIdScalar)
  conversationId: Types.ObjectId;

  @Field({ nullable: true })
  @IsOptional()
  pagination?: PaginationInput;
}
