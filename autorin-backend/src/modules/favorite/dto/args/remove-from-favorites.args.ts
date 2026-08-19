import { ArgsType, Field } from '@nestjs/graphql';
import { FavoriteInput } from '../inputs';

@ArgsType()
export class RemoveFromFavoritesArgs {
  @Field()
  favorite: FavoriteInput;
}
