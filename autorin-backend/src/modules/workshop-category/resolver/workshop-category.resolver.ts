import { Context, Parent, Query, ResolveField, Resolver } from '@nestjs/graphql';
import { Request } from 'express';
import { Public } from 'src/auth/decorators';
import { CategoryNames } from 'src/modules/category/types/category-names.type';
import {
  pickCategoryName,
  resolveCategoryNamesFromDoc,
} from 'src/modules/category/utils/category-names.util';
import { WorkshopCategory } from '../schema/workshop-category.schema';
import { WorkshopCategoryService } from '../service/workshop-category.service';

function localeFromRequest(req?: Request): string | undefined {
  const raw = req?.headers?.['accept-language'];
  if (typeof raw === 'string' && raw.trim()) {
    return raw.split(',')[0].trim();
  }
  return undefined;
}

@Resolver(() => WorkshopCategory)
export class WorkshopCategoryResolver {
  constructor(private readonly categoryService: WorkshopCategoryService) {}

  @ResolveField(() => CategoryNames)
  names(
    @Parent() category: WorkshopCategory & { name?: string; names?: unknown },
  ): CategoryNames {
    return resolveCategoryNamesFromDoc(category);
  }

  @ResolveField(() => String)
  name(
    @Parent() category: WorkshopCategory & { name?: string; names?: unknown },
    @Context() ctx: { req?: Request },
  ): string {
    const names = resolveCategoryNamesFromDoc(category);
    return pickCategoryName(names, localeFromRequest(ctx?.req));
  }

  @Public()
  @Query(() => [WorkshopCategory], { name: 'workshopCategories' })
  workshopCategories(@Context() ctx: { req?: Request }) {
    return this.categoryService.list(localeFromRequest(ctx?.req));
  }
}
