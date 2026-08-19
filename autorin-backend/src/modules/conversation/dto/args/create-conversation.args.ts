import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { CreateConversationInput } from '../inputs';

@ArgsType()
export class CreateConversationArgs {
  @Field()
  @DeepValidate()
  data: CreateConversationInput;
}
