import { Args, Context, Mutation, Query, Resolver, Subscription } from '@nestjs/graphql';
import { Inject } from '@nestjs/common';
import type { RedisPubSub } from 'graphql-redis-subscriptions';
import { Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { UseAuth, UseWsAuth } from 'src/auth/useAuth';
import { ObjectIdScalar } from 'src/common';
import { PUBSUB, TRIGGERS } from 'src/pubsub';
import { RespondToOrderArgs } from '../dto/respond-to-order.args';
import { OrderResponse } from '../schema/order-response.schema';
import { OrderResponseService } from '../service/order-response.service';

@Resolver(() => OrderResponse)
export class OrderResponseResolver {
  constructor(
    private readonly service: OrderResponseService,
    @Inject(PUBSUB) private readonly pubSub: RedisPubSub,
  ) {}

  @UseAuth()
  @Query(() => [OrderResponse])
  async getOrderResponses(
    @Args('orderId', { type: () => ObjectIdScalar }) orderId: Types.ObjectId,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const canWatch = await this.service.canWatchOrder(userId, orderId);
    if (!canWatch) return [];
    return this.service.list(orderId);
  }

  @UseAuth()
  @Mutation(() => OrderResponse)
  respondToOrder(
    @Args() { data }: RespondToOrderArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.service.respond(userId, data);
  }

  @UseWsAuth()
  @Subscription(() => OrderResponse, {
    resolve: (payload: { orderResponseAdded: OrderResponse }) =>
      payload.orderResponseAdded,
  })
  async orderResponseAdded(
    @Args('orderId', { type: () => ObjectIdScalar }) orderId: Types.ObjectId,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    await this.service.assertCanWatchOrder(userId, orderId);
    return this.pubSub.asyncIterator(
      TRIGGERS.ORDER_RESPONSE_ADDED(orderId.toString()),
    );
  }
}
