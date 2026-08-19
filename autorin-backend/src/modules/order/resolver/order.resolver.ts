import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import {
  CreateOrderArgs,
  GetOrderByIdArgs,
  GetOrdersArgs,
  UpdateOrderByIdArgs,
} from '../dto';
import { Order } from '../schema';
import { OrderService } from '../service';
import { PaginatedOrders } from '../types';

@Resolver()
export class OrderResolver {
  constructor(private readonly orderService: OrderService) {}

  @UseOptionalAuth()
  @Query(() => PaginatedOrders)
  getOrders(@Args() args: GetOrdersArgs, @Context() context: ContextType) {
    return this.orderService.getOrders(args, context);
  }

  @UseOptionalAuth()
  @Query(() => Order)
  getOrderById(
    @Args() args: GetOrderByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.orderService.getOrderById(args, context);
  }

  @UseAuth()
  @Mutation(() => Order)
  createOrder(@Args() args: CreateOrderArgs, @Context() context: ContextType) {
    return this.orderService.createOrder(args, context);
  }

  @UseAuth()
  @Mutation(() => Order)
  updateOrderById(
    @Args() args: UpdateOrderByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.orderService.updateOrderById(args, context);
  }

  @UseAuth()
  @Mutation(() => Order)
  closeOrderById(
    @Args() args: GetOrderByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.orderService.closeOrderById(args, context);
  }

  @UseAuth()
  @Mutation(() => Order)
  reopenOrderById(
    @Args() args: GetOrderByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.orderService.reopenOrderById(args, context);
  }

  @UseAuth()
  @Mutation(() => Order)
  deleteOrderById(
    @Args() args: GetOrderByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.orderService.deleteOrderById(args, context);
  }
}
