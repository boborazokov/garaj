import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class RecordAdvertisementArgs {
  @Field(() => ObjectIdScalar)
  advertisementId: Types.ObjectId;
}
