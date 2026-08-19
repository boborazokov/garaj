import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { SendMessageInput } from '../inputs';

@ArgsType()
export class SendMessageArgs {
  @Field()
  @DeepValidate()
  data: SendMessageInput;
}
