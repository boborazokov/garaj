import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class GetPartByIdArgs {
  @Field(() => ObjectIdScalar)
  partId: Types.ObjectId;
}
