import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { PUBSUB, TRIGGERS } from 'src/pubsub';
import type { RedisPubSub } from 'graphql-redis-subscriptions';
import {
  ConversationIdArgs,
  CreateConversationInput,
  GetConversationsArgs,
} from '../dto';
import { Message } from 'src/modules/message/schema';
import { Conversation } from '../schema';
import { ConversationView } from '../types/conversation-summary.type';
import {
  LIMIT_DEFAULT,
  PAGE_DEFAULT,
} from 'src/shared/inputs/pagination.input';

@Injectable()
export class ConversationService {
  constructor(
    @InjectModel(COLLECTIONS.CONVERSATIONS)
    private readonly model: Model<Conversation>,
    @InjectModel(COLLECTIONS.MESSAGES)
    private readonly messageModel: Model<Message>,
    @Inject(PUBSUB) private readonly pubSub: RedisPubSub,
  ) {}

  /**
   * Sort participant ids deterministically so the array can be matched
   * with `$all` + `$size: 2` without false negatives caused by order.
   */
  private sortPair(a: Types.ObjectId, b: Types.ObjectId): Types.ObjectId[] {
    return [a, b].sort((x, y) => x.toString().localeCompare(y.toString()));
  }

  /**
   * Atomically reads an existing conversation between two users
   * (optionally scoped to a Part) or creates one.
   *
   * Uses `findOneAndUpdate({ upsert })` with `$setOnInsert` to avoid
   * the classic race where two concurrent calls insert duplicates.
   */
  async findOrCreate(
    viewer: Types.ObjectId,
    input: CreateConversationInput,
  ): Promise<Conversation> {
    if (viewer.equals(input.recipientId)) {
      throw new BadRequestException('Cannot start a conversation with yourself');
    }
    const participants = this.sortPair(viewer, input.recipientId);

    // Exact-array equality works because `participants` is always
    // sorted deterministically (see `sortPair`). Using `$all`+`$size`
    // here would conflict with `$setOnInsert.participants` because
    // MongoDB cannot infer a single value for the field from those
    // operators during an upsert (error: "path 'participants' is
    // matched twice").
    const filter: Record<string, unknown> = {
      participants,
      part: input.partId ?? null,
    };

    const conv = await this.model.findOneAndUpdate(
      filter,
      {
        $setOnInsert: {
          unreadCounts: {},
          lastMessageAt: new Date(),
        },
        // Restore visibility for both members if either had hidden it.
        // Not in $setOnInsert — Mongo rejects updating the same path
        // with $setOnInsert and $pull in one op.
        $pull: { hiddenFor: { $in: participants } },
      },
      { upsert: true, new: true, setDefaultsOnInsert: true },
    );

    return conv.populate(['participants', 'part']);
  }

  /** Throws ForbiddenException if `viewer` is not in the conversation. */
  async assertParticipant(
    viewer: Types.ObjectId,
    conversationId: Types.ObjectId,
  ): Promise<void> {
    const ok = await this.model.exists({
      _id: conversationId,
      participants: viewer,
    });
    if (!ok) throw new ForbiddenException('Not a participant');
  }

  async list(
    viewer: Types.ObjectId,
    args: GetConversationsArgs,
  ): Promise<{
    payload: ConversationView[];
    totalDocs: number;
    page: number;
    limit: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPrevPage: boolean;
    nextPage: number | null;
    prevPage: number | null;
  }> {
    const page = args.pagination?.page ?? PAGE_DEFAULT;
    const limit = Math.min(args.pagination?.limit ?? LIMIT_DEFAULT, 50);

    const filter = {
      participants: viewer,
      hiddenFor: { $ne: viewer },
    };

    const [docs, totalDocs] = await Promise.all([
      this.model
        .find(filter)
        .sort({ lastMessageAt: -1, _id: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('participants', 'name phone address role')
        .populate('part', 'name images price currency')
        .lean(),
      this.model.countDocuments(filter),
    ]);

    // Project a viewer-scoped `unread` field. Lean docs return the
    // Mongoose Map as a plain object; we read it as such.
    const payload: ConversationView[] = docs.map((d) => {
      const counts =
        ((d as unknown as { unreadCounts?: Record<string, number> })
          .unreadCounts ?? {}) as Record<string, number>;
      const unread = Number(counts[viewer.toString()] ?? 0);
      return Object.assign({}, d, { unread }) as unknown as ConversationView;
    });

    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));
    return {
      payload,
      totalDocs,
      page,
      limit,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
      nextPage: page < totalPages ? page + 1 : null,
      prevPage: page > 1 ? page - 1 : null,
    };
  }

  /**
   * Resets the viewer's unread counter and marks all unread inbound
   * messages as read in one atomic dual-update.
   */
  async markAsRead(
    viewer: Types.ObjectId,
    conversationId: Types.ObjectId,
  ): Promise<Conversation> {
    const [conv] = await Promise.all([
      this.model.findOneAndUpdate(
        { _id: conversationId, participants: viewer },
        { $set: { [`unreadCounts.${viewer.toString()}`]: 0 } },
        { new: true },
      ),
      this.messageModel.updateMany(
        {
          conversation: conversationId,
          sender: { $ne: viewer },
          readBy: { $ne: viewer },
        },
        { $addToSet: { readBy: viewer } },
      ),
    ]);
    if (!conv) throw new BadRequestException('Conversation not found');

    // Publish so the inbox badge updates in realtime.
    await this.pubSub.publish(TRIGGERS.UNREAD_CHANGED(viewer.toString()), {
      unreadCountChanged: {
        conversationId,
        userId: viewer,
        unread: 0,
      },
    });

    // Notify senders that their outbound messages were read (read receipts).
    const readReceipts = await this.messageModel
      .find({
        conversation: conversationId,
        sender: { $ne: viewer },
        readBy: viewer,
      })
      .sort({ createdAt: -1 })
      .limit(30)
      .populate('sender', 'name phone role');

    await Promise.all(
      readReceipts.map((msg) =>
        this.pubSub.publish(
          TRIGGERS.MESSAGE_SENT(conversationId.toString()),
          { messageReceived: msg.toObject() },
        ),
      ),
    );

    return conv.populate(['participants', 'part']);
  }

  async deleteForMe(
    viewer: Types.ObjectId,
    { conversationId }: ConversationIdArgs,
  ): Promise<boolean> {
    const res = await this.model.updateOne(
      { _id: conversationId, participants: viewer },
      { $addToSet: { hiddenFor: viewer } },
    );
    return res.modifiedCount > 0;
  }
}
