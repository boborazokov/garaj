import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';

/** One row per user per calendar day (Asia/Tashkent) — for DAU reporting. */
@Schema({ collection: COLLECTIONS.DAILY_USER_VISITS, timestamps: true })
export class DailyUserVisit {
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, required: true })
  userId: Types.ObjectId;

  /** `YYYY-MM-DD` in Asia/Tashkent */
  @Prop({ type: String, required: true, index: true })
  day: string;
}

export const DailyUserVisitSchema =
  SchemaFactory.createForClass(DailyUserVisit);

DailyUserVisitSchema.index({ userId: 1, day: 1 }, { unique: true });
DailyUserVisitSchema.index({ day: 1 });
