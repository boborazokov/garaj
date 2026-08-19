import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CategoryTypeEnum } from 'src/modules/category/enums';

@ObjectType()
@Schema({ timestamps: true })
export class Advertisement {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ required: true })
  type: CategoryTypeEnum;

  @Field()
  @Prop({ required: true })
  bannerImageUrl: string;

  @Field()
  @Prop({ required: true })
  title: string;

  @Field()
  @Prop({ required: true })
  link: string;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
