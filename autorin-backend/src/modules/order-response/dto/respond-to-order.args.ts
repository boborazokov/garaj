import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { RespondToOrderInput } from './respond-to-order.input';

@ArgsType()
export class RespondToOrderArgs {
  @Field()
  @DeepValidate()
  data: RespondToOrderInput;
}
