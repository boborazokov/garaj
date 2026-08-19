import { Query, Resolver } from '@nestjs/graphql';
import { Public } from 'src/auth/decorators';
import { ServiceCategory } from '../schema/service-category.schema';
import { ServiceCategoryService } from '../service/service-category.service';

@Resolver(() => ServiceCategory)
export class ServiceCategoryResolver {
  constructor(private readonly categoryService: ServiceCategoryService) {}

  /** Static taxonomy — no personalization. */
  @Public()
  @Query(() => [ServiceCategory], { name: 'serviceCategories' })
  serviceCategories() {
    return this.categoryService.list();
  }
}
