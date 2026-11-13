import { Int, Parent, ResolveField, Resolver } from '@nestjs/graphql';
import { Order } from '../schema';

/** Defaults for older Mongo docs missing engagement counters. */
@Resolver(() => Order)
export class OrderFieldsResolver {
  @ResolveField(() => Int)
  viewsCount(@Parent() order: Order) {
    return Number(order.viewsCount ?? 0);
  }

  @ResolveField(() => Int)
  phoneClickCount(@Parent() order: Order) {
    return Number(order.phoneClickCount ?? 0);
  }

  @ResolveField(() => Int)
  shareCount(@Parent() order: Order) {
    return Number(order.shareCount ?? 0);
  }
}
