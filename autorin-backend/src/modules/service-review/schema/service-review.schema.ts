import { Field, Float, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { User } from 'src/modules/user/schema';

@ObjectType()
@Schema({ timestamps: true })
export class ServiceReview {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => AutoService)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.SERVICES, required: true, index: true })
  service: AutoService | Types.ObjectId;

  @Field(() => User)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, required: true, index: true })
  user: User | Types.ObjectId;

  @Field(() => Float)
  @Prop({ required: true, min: 1, max: 5 })
  rating: number;

  @Field()
  @Prop({ default: '' })
  text: string;

  @Field()
  createdAt: Date;
}
