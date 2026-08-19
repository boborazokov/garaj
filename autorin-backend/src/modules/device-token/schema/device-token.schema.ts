import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { User } from 'src/modules/user/schema';
import { DevicePlatformEnum } from '../enums';

/**
 * One row per (user, FCM registration token).
 *
 * Design decisions:
 *  - The `token` itself is the unique key (a token belongs to ONE device
 *    install at a time; if the same install changes account we update
 *    the `user` reference rather than create a duplicate).
 *  - `isActive` is a soft flag so we don't lose token history when FCM
 *    reports `messaging/registration-token-not-registered`; the worker
 *    just disables it and the next login refreshes a working one.
 *  - `(user, isActive)` lets the push service pull all live tokens for
 *    a user in a single index scan.
 */
@ObjectType()
@Schema({ timestamps: true })
export class DeviceToken {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => User)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    required: true,
    index: true,
  })
  user: User | Types.ObjectId;

  @Field()
  @Prop({ required: true, unique: true })
  token: string;

  @Field(() => DevicePlatformEnum)
  @Prop({
    type: String,
    enum: Object.values(DevicePlatformEnum),
    required: true,
  })
  platform: DevicePlatformEnum;

  @Field({ nullable: true })
  @Prop({ default: '' })
  locale?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  appVersion?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  deviceModel?: string;

  @Field()
  @Prop({ default: true, index: true })
  isActive: boolean;

  /** Last time the client confirmed it owns this token (login / app open). */
  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: () => new Date() })
  lastSeenAt?: Date;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
