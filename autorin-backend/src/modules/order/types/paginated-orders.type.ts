import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { Order } from '../schema';

@ObjectType()
export class PaginatedOrders extends PaginationResult {
  @Field(() => [Order])
  payload: Order[];
}
