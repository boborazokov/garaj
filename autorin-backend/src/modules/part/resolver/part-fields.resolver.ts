import { Context, Parent, ResolveField, Resolver } from '@nestjs/graphql';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { COLLECTIONS } from 'src/constants';
import { Favorite } from 'src/modules/favorite/schema';
import { Part } from '../schema';

@Resolver(() => Part)
export class PartFieldsResolver {
  constructor(
    @InjectModel(COLLECTIONS.FAVORITES)
    private readonly favoriteModel: Model<Favorite>,
  ) {}

  @ResolveField(() => Boolean, { name: 'isFavorite' })
  async isFavorite(
    @Parent() part: Part,
    @Context() ctx: ContextType,
  ): Promise<boolean> {
    if (!ctx.userId) {
      return false;
    }

    const fav = await this.favoriteModel
      .findOne({ userId: ctx.userId })
      .select('partsIds')
      .lean()
      .exec();

    if (!fav?.partsIds?.length) {
      return false;
    }

    const partId = part._id.toString();
    return fav.partsIds.some((id) => id.toString() === partId);
  }
}
