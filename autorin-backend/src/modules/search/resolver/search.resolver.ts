import { Args, Context, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { OptionalAuthResolver } from 'src/auth/useAuth';
import { SearchProductsArgs } from '../dto/search-products.args';
import { SearchService } from '../service/search.service';
import { SearchProductsResult } from '../types/search-products-result.type';

/** Product search — guest browse; optional token for ranking/region hints. */
@OptionalAuthResolver()
@Resolver()
export class SearchResolver {
  constructor(private readonly searchService: SearchService) {}

  @Query(() => SearchProductsResult)
  searchProducts(
    @Args() args: SearchProductsArgs,
    @Context() context: ContextType,
  ) {
    return this.searchService.searchProducts(args, context);
  }
}
