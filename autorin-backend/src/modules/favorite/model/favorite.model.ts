import { ModelDefinition } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { FavoriteSchema } from '../schema';

export const FavoriteModel: ModelDefinition = {
  name: COLLECTIONS.FAVORITES,
  schema: FavoriteSchema,
};
