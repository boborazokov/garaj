import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type SessionDocument = HydratedDocument<Session>;

@Schema({ collection: 'sessions', timestamps: true })
export class Session {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ required: true, unique: true })
  refreshTokenHash!: string;

  @Prop({ required: true, index: true })
  deviceId!: string;

  @Prop()
  deviceName?: string;

  @Prop({ required: true })
  tokenVersion!: number;

  @Prop({ required: true })
  expiresAt!: Date;

  @Prop()
  lastUsedAt?: Date;

  @Prop()
  revokedAt?: Date;

  @Prop()
  ip?: string;

  @Prop()
  userAgent?: string;
}

export const SessionSchema = SchemaFactory.createForClass(Session);

SessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
SessionSchema.index({ userId: 1, deviceId: 1 });
SessionSchema.index({ userId: 1, revokedAt: 1 });
