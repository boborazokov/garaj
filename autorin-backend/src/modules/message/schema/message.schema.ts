import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { User } from 'src/modules/user/schema';

/**
 * Limits chosen to match what the mobile UI is willing to render
 * comfortably and to bound abuse vectors. Validation lives on the
 * resolver Input as well; these constants exist for tests / reuse.
 */
export const MESSAGE_TEXT_MAX = 4096;
export const MESSAGE_IMAGES_MAX = 10;
export const MESSAGE_VOICE_MAX_DURATION_MS = 5 * 60 * 1000;

@ObjectType()
@Schema({ timestamps: true })
export class Message {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.CONVERSATIONS,
    required: true,
    index: true,
  })
  conversation: Types.ObjectId;

  @Field(() => User)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    required: true,
    index: true,
  })
  sender: User | Types.ObjectId;

  @Field({ nullable: true })
  @Prop({ default: '', maxlength: MESSAGE_TEXT_MAX })
  text?: string;

  @Field(() => [String])
  @Prop({ type: [String], default: [] })
  images: string[];

  /**
   * Per-user read receipts. We deliberately store an array of user IDs
   * rather than a boolean: 1:1 chats stay simple while leaving the
   * door open for group chats without a migration.
   */
  @Field(() => [ObjectIdScalar])
  @Prop({ type: [Types.ObjectId], default: [] })
  readBy: Types.ObjectId[];

  /**
   * "Delete for me". The message stays in the DB so the other
   * participant still sees it; only the requester's render hides it.
   */
  @Field(() => [ObjectIdScalar])
  @Prop({ type: [Types.ObjectId], default: [] })
  deletedFor: Types.ObjectId[];

  /**
   * Optional reference to another message in the same conversation that
   * this one replies to (Telegram-style quote-reply).
   */
  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.MESSAGES,
    default: null,
    index: true,
  })
  replyTo?: Types.ObjectId | null;

  /** Snapshot of the replied-to message text. Avoids extra populates. */
  @Field({ nullable: true })
  @Prop({ default: '' })
  replyToText?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  replyToSenderName?: string;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    default: null,
  })
  replyToSenderId?: Types.ObjectId | null;

  /** Public URL to the voice file (m4a/ogg/opus), if this is a voice message. */
  @Field({ nullable: true })
  @Prop({ default: '' })
  voiceUrl?: string;

  @Field({ nullable: true })
  @Prop({ default: 0 })
  voiceDurationMs?: number;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;
}
