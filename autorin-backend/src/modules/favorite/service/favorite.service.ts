import { BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Favorite } from '../schema';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { ContextType } from 'src/auth/interfaces';
import {
  AddToFavoritesArgs,
  FavoriteInput,
  RemoveFromFavoritesArgs,
} from '../dto';

export class FavoriteService {
  constructor(
    @InjectModel(COLLECTIONS.FAVORITES) private favoriteModel: Model<Favorite>,
  ) {}

  async initFavorite(userId: Types.ObjectId) {
    const foundFavorite = await this.favoriteModel.exists({ userId });

    if (!foundFavorite) {
      await this.favoriteModel.create({
        userId,
        partsIds: [],
        servicesIds: [],
      });
    }
  }

  private buildFavoriteUpdate(
    favorite: FavoriteInput,
    op: 'add' | 'remove',
  ): Record<string, unknown> {
    const { partId, serviceId } = favorite;
    if (!partId && !serviceId) {
      throw new BadRequestException(
        'At least one of partId or serviceId must be provided',
      );
    }
    if (partId) {
      return op === 'add'
        ? { $addToSet: { partsIds: partId } }
        : { $pull: { partsIds: partId } };
    }
    return op === 'add'
      ? { $addToSet: { servicesIds: serviceId } }
      : { $pull: { servicesIds: serviceId } };
  }

  async addToFavorites(
    { favorite }: AddToFavoritesArgs,
    { userId }: ContextType,
  ) {
    const uid = new Types.ObjectId(userId);
    await this.initFavorite(uid);

    await this.favoriteModel.updateOne(
      { userId: uid },
      this.buildFavoriteUpdate(favorite, 'add'),
    );

    return this.getFavorites(uid);
  }

  async getFavorites(userId: Types.ObjectId) {
    const foundFavorite = await this.favoriteModel
      .findOne({ userId })
      .exec();

    if (!foundFavorite) {
      const createdFavorite = await this.favoriteModel.create({
        userId,
        partsIds: [],
        servicesIds: [],
      });

      return createdFavorite;
    }

    return foundFavorite;
  }

  async removeFromFavorites(
    { favorite }: RemoveFromFavoritesArgs,
    { userId }: ContextType,
  ) {
    const uid = new Types.ObjectId(userId);
    await this.initFavorite(uid);

    await this.favoriteModel.updateOne(
      { userId: uid },
      this.buildFavoriteUpdate(favorite, 'remove'),
    );

    return this.getFavorites(uid);
  }
}
