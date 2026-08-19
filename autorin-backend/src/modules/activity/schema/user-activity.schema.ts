import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { ActivityTypeEnum } from '../enums';

@ObjectType()
@Schema({ timestamps: { createdAt: true, updatedAt: false } })
export class UserActivity {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, index: true })
  userId?: Types.ObjectId;

  @Field(() => ActivityTypeEnum)
  @Prop({ type: String, enum: Object.values(ActivityTypeEnum), index: true })
  type: ActivityTypeEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, index: true })
  entityId?: Types.ObjectId;

  @Field(() => String, { nullable: true })
  @Prop({ type: Object, default: {} })
  metadata?: Record<string, unknown>;

  @Field()
  createdAt: Date;
}

export const UserActivitySchema = SchemaFactory.createForClass(UserActivity);

UserActivitySchema.index({ userId: 1, createdAt: -1 });
UserActivitySchema.index({ type: 1, createdAt: -1 });
UserActivitySchema.index({ entityId: 1, type: 1 });
