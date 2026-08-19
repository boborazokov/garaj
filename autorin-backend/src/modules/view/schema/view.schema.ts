import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { ViewTargetTypeEnum } from '../enums';

@Schema({ timestamps: true })
@ObjectType()
export class View {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop()
  targetId: Types.ObjectId;

  @Field(() => ViewTargetTypeEnum)
  @Prop({ type: String, enum: Object.values(ViewTargetTypeEnum) })
  targetType: ViewTargetTypeEnum;

  @Field(() => ObjectIdScalar)
  @Prop()
  userId: Types.ObjectId;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}

export const ViewSchema = SchemaFactory.createForClass(View);
