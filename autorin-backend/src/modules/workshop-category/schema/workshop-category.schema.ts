import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CategoryNames } from 'src/modules/category/types/category-names.type';

@ObjectType()
@Schema({ timestamps: true })
export class WorkshopCategory {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop({ required: true, unique: true, index: true })
  slug: string;

  @Field(() => CategoryNames)
  @Prop({ type: CategoryNames, required: true })
  names: CategoryNames;

  @Field({ nullable: true })
  @Prop({ default: 'wrench' })
  icon?: string;

  @Field({ nullable: true })
  @Prop({ default: '#4361EE' })
  color?: string;

  @Field({ nullable: true })
  @Prop({ default: false, index: true })
  popular?: boolean;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
