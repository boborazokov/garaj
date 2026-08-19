import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@InputType()
export class ViewsTargetInput {
  @Field(() => ObjectIdScalar)
  partId: Types.ObjectId;
}
