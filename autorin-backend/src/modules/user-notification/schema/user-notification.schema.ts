import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';

@Schema({ timestamps: { createdAt: true, updatedAt: false } })
export class UserNotification {
  @Prop({ type: Types.ObjectId, required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ type: String, required: true })
  type: string;

  @Prop({ required: true, trim: true })
  title: string;

  @Prop({ required: true, trim: true })
  body: string;

  @Prop({ trim: true })
  deepLink?: string;

  @Prop({ type: Map, of: String, default: {} })
  data: Map<string, string>;

  @Prop({ type: Date, default: null })
  readAt?: Date | null;

  createdAt: Date;
}

export const UserNotificationSchema = SchemaFactory.createForClass(UserNotification);
UserNotificationSchema.index({ userId: 1, createdAt: -1 });
UserNotificationSchema.index({ userId: 1, readAt: 1 });
