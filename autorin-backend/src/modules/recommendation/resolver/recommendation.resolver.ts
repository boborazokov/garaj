import { Args, Context, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { OptionalAuthResolver } from 'src/auth/useAuth';
import { Order } from 'src/modules/order/schema';
import { Part } from 'src/modules/part/schema';
import {
  NearbyProductsArgs,
  RecommendationListArgs,
  SimilarProductsArgs,
} from '../dto/recommendation.args';
import { RecommendationService } from '../service/recommendation.service';

/** Home/discovery feed — guests browse; logged-in users get personalization. */
@OptionalAuthResolver()
@Resolver()
export class RecommendationResolver {
  constructor(private readonly recommendationService: RecommendationService) {}

  @Query(() => [Part])
  recommendedProducts(
    @Args() args: RecommendationListArgs,
    @Context() context: ContextType,
  ) {
    return this.recommendationService.recommendedProducts(args, context);
  }

  @Query(() => [Part])
  similarProducts(@Args() args: SimilarProductsArgs) {
    return this.recommendationService.similarProducts(args);
  }

  @Query(() => [Part])
  trendingProducts(@Args() args: RecommendationListArgs) {
    return this.recommendationService.trendingProducts(
      args.city,
      args.limit ?? 12,
    );
  }

  @Query(() => [Part])
  nearbyProducts(
    @Args() args: NearbyProductsArgs,
    @Context() context: ContextType,
  ) {
    return this.recommendationService.nearbyProducts(args, context);
  }

  @Query(() => [Part])
  recentlyViewedProducts(
    @Args() args: RecommendationListArgs,
    @Context() context: ContextType,
  ) {
    return this.recommendationService.recentlyViewedProducts(args, context);
  }

  @Query(() => [Part])
  newArrivals(@Args() args: RecommendationListArgs) {
    return this.recommendationService.newArrivals(args.limit ?? 12);
  }

  @Query(() => [Order])
  recommendedOrders(
    @Args() args: RecommendationListArgs,
    @Context() context: ContextType,
  ) {
    return this.recommendationService.recommendedOrders(args, context);
  }
}
