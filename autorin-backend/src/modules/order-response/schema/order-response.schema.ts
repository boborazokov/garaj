import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { Part } from 'src/modules/part/schema';
import { User } from 'src/modules/user/schema';

@ObjectType()
@Schema({ timestamps: true })
export class OrderResponse {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.ORDERS,
    required: true,
    index: true,
  })
  order: Types.ObjectId;

  @Field(() => User)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    required: true,
    index: true,
  })
  seller: User | Types.ObjectId;

  /** Seller's marketplace listing offered for this request (optional). */
  @Field(() => Part, { nullable: true })
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.PARTS,
    default: null,
    index: true,
  })
  part?: Part | Types.ObjectId | null;

  @Field()
  @Prop({ required: true, maxlength: 2000 })
  text: string;

  @Field({ nullable: true })
  @Prop({ default: null, min: 0 })
  offeredPrice?: number;

  @Field({ nullable: true })
  @Prop({ default: null, min: 0 })
  deliveryDays?: number;

  @Field()
  @Prop({ default: false })
  isAccepted: boolean;

  @Field()
  createdAt: Date;
}
