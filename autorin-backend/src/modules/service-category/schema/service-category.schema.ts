import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';

@ObjectType()
@Schema({ timestamps: true })
export class ServiceCategory {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ required: true, unique: true, index: true })
  slug: string;

  @Field()
  @Prop({ required: true })
  name: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  iconUrl?: string;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
