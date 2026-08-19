import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { FavoriteService } from '../service';
import { AddToFavoritesArgs, RemoveFromFavoritesArgs } from '../dto';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { Favorite } from '../schema';
import { UseAuth } from 'src/auth/useAuth';

@Resolver()
export class FavoriteResolver {
  constructor(private favoriteService: FavoriteService) {}

  @Mutation(() => Favorite)
  @UseAuth()
  async addToFavorites(
    @Args() args: AddToFavoritesArgs,
    @Context() context: ContextType,
  ) {
    return this.favoriteService.addToFavorites(args, context);
  }

  @Query(() => Favorite)
  @UseAuth()
  async getFavorites(@Context() context: ContextType) {
    const { userId } = assertAuthenticated(context);
    return this.favoriteService.getFavorites(userId);
  }

  @Mutation(() => Favorite)
  @UseAuth()
  async removeFromFavorites(
    @Args() args: RemoveFromFavoritesArgs,
    @Context() context: ContextType,
  ) {
    return this.favoriteService.removeFromFavorites(args, context);
  }
}
