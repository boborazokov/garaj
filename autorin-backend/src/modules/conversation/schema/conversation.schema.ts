import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { Part } from 'src/modules/part/schema';
import { User } from 'src/modules/user/schema';

/**
 * A 1:1 conversation between two users, optionally scoped to a Part.
 *
 * Design:
 *  - `participants` is always stored sorted ascending by ObjectId so
 *    `findOrCreate` can use the same array for both members and rely
 *    on a single index lookup.
 *  - `part` is optional; chats started from a Part page are scoped to
 *    that listing so a buyer can have *separate* threads with the same
 *    seller about different parts.
 *  - `unreadCounts` is a `Map<userId, count>`. Storing it on the
 *    conversation (not on a join table) means we can return the unread
 *    badge in the same document that drives the inbox row — no extra
 *    queries.
 *  - `hiddenFor` is a soft "delete for me" list. The next message
 *    automatically pulls the user back into the thread (handled in
 *    MessageService.send).
 */
@ObjectType()
@Schema({ timestamps: true })
export class Conversation {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => [User])
  @Prop({
    type: [{ type: Types.ObjectId, ref: COLLECTIONS.USERS }],
    required: true,
    index: true,
  })
  participants: (User | Types.ObjectId)[];

  @Field(() => Part, { nullable: true })
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.PARTS,
    default: null,
    index: true,
  })
  part?: Part | Types.ObjectId | null;

  @Field({ nullable: true })
  @Prop({ default: '' })
  lastMessageText?: string;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, default: null })
  lastMessageSender?: Types.ObjectId | null;

  @Field(() => Date, { nullable: true })
  @Prop({ type: Date, default: null, index: true })
  lastMessageAt?: Date | null;

  /**
   * Mongo Maps render to plain objects in JSON. We expose unread for a
   * specific user via a resolver field rather than the raw map, so the
   * GraphQL contract doesn't leak other users' counters.
   */
  @Prop({ type: Map, of: Number, default: {} })
  unreadCounts: Map<string, number>;

  @Field(() => [ObjectIdScalar])
  @Prop({
    type: [{ type: Types.ObjectId, ref: COLLECTIONS.USERS }],
    default: [],
  })
  hiddenFor: Types.ObjectId[];

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;
}
