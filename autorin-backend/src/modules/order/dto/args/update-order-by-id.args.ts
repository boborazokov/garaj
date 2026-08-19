import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { OrderUpdateInput } from '../inputs';
import { GetOrderByIdArgs } from './get-order-by-id.args';

@ArgsType()
export class UpdateOrderByIdArgs extends GetOrderByIdArgs {
  @Field()
  @DeepValidate()
  data: OrderUpdateInput;
}
