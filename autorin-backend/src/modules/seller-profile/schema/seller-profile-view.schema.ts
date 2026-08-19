import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ObjectType()
@Schema({ timestamps: true })
export class SellerProfileView {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({ type: Types.ObjectId, ref: 'users', required: true, index: true })
  viewerId: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({ type: Types.ObjectId, ref: 'users', required: true, index: true })
  sellerId: Types.ObjectId;

  @Field()
  createdAt: Date;
}
