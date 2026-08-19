import { ArgsType, Field } from '@nestjs/graphql';
import { PaginationInput } from 'src/shared/inputs';
import { AdvertisementFilterInput } from '../inputs';

@ArgsType()
export class AdminListAdvertisementsArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field(() => AdvertisementFilterInput, { nullable: true })
  filter?: AdvertisementFilterInput;
}
