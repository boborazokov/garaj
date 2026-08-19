import { Field, Float, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { Workshop } from 'src/modules/workshop/schema/workshop.schema';
import { User } from 'src/modules/user/schema';

@ObjectType()
export class WorkshopReviewOwnerReply {
  @Field()
  text: string;

  @Field()
  repliedAt: Date;
}

@ObjectType()
@Schema({ timestamps: true })
export class WorkshopReview {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => Workshop)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.WORKSHOPS, required: true, index: true })
  workshop: Workshop | Types.ObjectId;

  @Field(() => User)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, required: true, index: true })
  user: User | Types.ObjectId;

  @Field(() => Float)
  @Prop({ required: true, min: 1, max: 5 })
  rating: number;

  @Field()
  @Prop({ default: '' })
  text: string;

  @Field(() => [String])
  @Prop({ type: [String], default: [] })
  images: string[];

  @Field(() => WorkshopReviewOwnerReply, { nullable: true })
  @Prop({
    type: {
      text: { type: String, default: '' },
      repliedAt: { type: Date },
    },
    default: null,
  })
  ownerReply?: WorkshopReviewOwnerReply | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
