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
  @Prop({ type: Types.ObjectId, required: true, index: true })
  targetId: Types.ObjectId;

  @Field(() => ViewTargetTypeEnum)
  @Prop({
    type: String,
    enum: Object.values(ViewTargetTypeEnum),
    required: true,
    index: true,
  })
  targetType: ViewTargetTypeEnum;

  /** Stable install id — one device counts once per listing. */
  @Field(() => String, { nullable: true })
  @Prop({ type: String, default: null, index: true })
  deviceId?: string | null;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, default: null, index: true })
  userId?: Types.ObjectId | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}

export const ViewSchema = SchemaFactory.createForClass(View);
ViewSchema.index(
  { targetType: 1, targetId: 1, deviceId: 1 },
  {
    unique: true,
    partialFilterExpression: { deviceId: { $type: 'string' } },
  },
);
