import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { UpdateMessageInput } from '../inputs';

@ArgsType()
export class UpdateMessageArgs {
  @Field()
  @DeepValidate()
  data: UpdateMessageInput;
}
