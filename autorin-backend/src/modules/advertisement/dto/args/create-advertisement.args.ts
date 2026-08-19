import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { AdvertisementInput } from '../inputs/advertisement.input';

@ArgsType()
export class CreateAdvertisementArgs {
  @Field()
  @DeepValidate()
  data: AdvertisementInput;
}
