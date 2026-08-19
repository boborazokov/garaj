import { ArgsType, Field } from '@nestjs/graphql';
import { AdvertisementFilterInput } from '../inputs';

@ArgsType()
export class GetAdvertisementsArgs {
  @Field(() => AdvertisementFilterInput, { nullable: true })
  filter?: AdvertisementFilterInput;
}
