import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { OrderInput } from '../inputs';

@ArgsType()
export class CreateOrderArgs {
  @Field()
  @DeepValidate()
  data: OrderInput;
}
