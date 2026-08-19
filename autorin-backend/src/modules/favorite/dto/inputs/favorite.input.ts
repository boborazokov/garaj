import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@InputType()
export class FavoriteInput {
  @Field(() => ObjectIdScalar, { nullable: true })
  partId?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  serviceId?: Types.ObjectId;
}
