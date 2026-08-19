import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CategoryTypeEnum } from '../enums';
import { CategoryNames } from '../types/category-names.type';

@ObjectType()
@Schema({ timestamps: true })
export class Category {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field({ nullable: true })
  @Prop({ default: '' })
  iconUrl: string;

  @Field({ nullable: true })
  @Prop({ trim: true, sparse: true, index: true })
  key?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  icon?: string;

  @Field(() => CategoryNames)
  @Prop({ type: CategoryNames, required: true })
  names: CategoryNames;

  @Field(() => CategoryTypeEnum)
  @Prop({
    type: String,
    enum: Object.values(CategoryTypeEnum),
    required: true,
    index: true,
  })
  type: CategoryTypeEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: 'categories', default: null, index: true })
  parentId?: Types.ObjectId | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
