import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';

@Schema({ collection: COLLECTIONS.AUTH_SESSIONS, timestamps: true })
export class AuthSession {
  @Prop({ type: Types.ObjectId, required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ required: true, unique: true })
  currentHash: string;

  @Prop({ index: true })
  previousHash?: string;

  @Prop({ required: true })
  expiresAt: Date;

  @Prop({ type: Date, default: null })
  revokedAt?: Date | null;

  @Prop({ type: Date, default: null })
  rotatedAt?: Date | null;

  @Prop()
  deviceId?: string;
}

export const AuthSessionSchema = SchemaFactory.createForClass(AuthSession);

AuthSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
