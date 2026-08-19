import { Field, ObjectType } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';

@ObjectType()
export class SellerFollower {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  name: string;

  @Field({ nullable: true })
  username?: string;

  @Field({ nullable: true })
  image?: string;

  @Field()
  followedAt: Date;
}
