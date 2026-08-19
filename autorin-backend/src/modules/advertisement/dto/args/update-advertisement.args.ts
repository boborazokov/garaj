import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { DeepValidate } from 'src/common';
import { AdvertisementInput } from '../inputs/advertisement.input';

@ArgsType()
export class UpdateAdvertisementArgs {
  @Field(() => ObjectIdScalar)
  advertisementId: Types.ObjectId;

  @Field()
  @DeepValidate()
  data: AdvertisementInput;
}
