import { Args, Int, Query, Resolver } from '@nestjs/graphql';
import { Public } from 'src/auth/decorators';
import { ViewService } from '../service';
import { GetTargetViewsCountArgs } from '../dto';

@Resolver()
export class ViewResolver {
  constructor(private viewService: ViewService) {}

  /** Public view counter for product/workshop cards. */
  @Public()
  @Query(() => Int)
  async getViewsCount(@Args() args: GetTargetViewsCountArgs) {
    return this.viewService.getTargetViewsCount(args);
  }
}
