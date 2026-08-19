import { ArgsType, Field } from '@nestjs/graphql';
import { FavoriteInput } from '../inputs';

@ArgsType()
export class AddToFavoritesArgs {
  @Field()
  favorite: FavoriteInput;
}
