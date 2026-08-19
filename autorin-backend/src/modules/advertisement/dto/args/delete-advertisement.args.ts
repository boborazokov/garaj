import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';

@ArgsType()
export class DeleteAdvertisementArgs {
  @Field(() => ObjectIdScalar)
  advertisementId: Types.ObjectId;
}
