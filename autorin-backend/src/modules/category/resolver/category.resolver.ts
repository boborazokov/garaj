import {
  Args,
  Context,
  Mutation,
  Parent,
  Query,
  ResolveField,
  Resolver,
} from '@nestjs/graphql';
import { Request } from 'express';
import { Public } from 'src/auth/decorators';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { UserRoleEnum } from 'src/modules/user/enums';
import { CategoryService } from '../service';
import { Category } from '../schema';
import {
  CreateCategoryArgs,
  DeleteCategoryArgs,
  GetCategoriesArgs,
  UpdateCategoryArgs,
} from '../dto';
import { CategoryNames } from '../types/category-names.type';
import { CategoryTreeNode } from '../types';
import { CategoryTypeEnum } from '../enums';
import {
  pickCategoryName,
  resolveCategoryNamesFromDoc,
} from '../utils/category-names.util';

function localeFromRequest(req?: Request): string | undefined {
  const raw = req?.headers?.['accept-language'];
  if (typeof raw === 'string' && raw.trim()) {
    return raw.split(',')[0].trim();
  }
  return undefined;
}

@Resolver(() => Category)
export class CategoryResolver {
  constructor(private categoryService: CategoryService) {}

  @ResolveField(() => CategoryNames)
  names(
    @Parent() category: Category & { name?: string | null; names?: unknown },
  ): CategoryNames {
    return resolveCategoryNamesFromDoc(category) as CategoryNames;
  }

  @ResolveField(() => String)
  name(
    @Parent() category: Category & { name?: string | null; names?: unknown },
    @Context() ctx: { req?: Request },
  ): string {
    const names = resolveCategoryNamesFromDoc(category);
    return pickCategoryName(names, localeFromRequest(ctx?.req));
  }

  @Public()
  @Query(() => [Category])
  getCategories(@Args() args: GetCategoriesArgs, @Context() ctx: { req?: Request }) {
    return this.categoryService.getCategories(args, localeFromRequest(ctx?.req));
  }

  @Public()
  @Query(() => [CategoryTreeNode])
  getCategoryTree(
    @Args('rootType', { type: () => CategoryTypeEnum, nullable: true })
    rootType?: CategoryTypeEnum,
    @Context() ctx?: { req?: Request },
  ) {
    return this.categoryService.getCategoryTree(
      rootType ?? CategoryTypeEnum.BRAND,
      localeFromRequest(ctx?.req),
    );
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Category)
  createCategory(@Args() args: CreateCategoryArgs) {
    return this.categoryService.createCategory(args);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Category)
  updateCategory(@Args() args: UpdateCategoryArgs) {
    return this.categoryService.updateCategory(args.categoryId, args.data);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Boolean)
  deleteCategory(@Args() args: DeleteCategoryArgs) {
    return this.categoryService.deleteCategory(args.categoryId);
  }
}
