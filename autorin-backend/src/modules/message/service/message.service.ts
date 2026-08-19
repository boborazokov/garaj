import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import type { RedisPubSub } from 'graphql-redis-subscriptions';
import { COLLECTIONS } from 'src/constants';
import { PUBSUB, TRIGGERS } from 'src/pubsub';
import { Conversation } from 'src/modules/conversation/schema';
import { PushService } from 'src/services/push';
import {
  GetMessagesArgs,
  SendMessageInput,
  TypingArgs,
} from '../dto';
import {
  MESSAGE_IMAGES_MAX,
  MESSAGE_TEXT_MAX,
  Message,
} from '../schema';
// `MESSAGE_VOICE_MAX_DURATION_MS` is enforced at the DTO layer via
// class-validator decorators (see send-message.input.ts).
import { AntiSpamService } from './anti-spam.service';
import {
  LIMIT_DEFAULT,
  PAGE_DEFAULT,
} from 'src/shared/inputs/pagination.input';

interface UserRefLike {
  _id: Types.ObjectId;
  name?: string;
}

@Injectable()
export class MessageService {
  constructor(
    @InjectModel(COLLECTIONS.MESSAGES)
    private readonly model: Model<Message>,
    @InjectModel(COLLECTIONS.CONVERSATIONS)
    private readonly conversationModel: Model<Conversation>,
    @Inject(PUBSUB) private readonly pubSub: RedisPubSub,
    private readonly push: PushService,
    private readonly antiSpam: AntiSpamService,
  ) {}

  /** Validates SendMessageInput beyond what class-validator can express. */
  private validatePayload(input: SendMessageInput): {
    text: string;
    images: string[];
    voiceUrl: string;
    voiceDurationMs: number;
  } {
    const text = (input.text ?? '').trim();
    const images = Array.isArray(input.images) ? input.images : [];
    const voiceUrl = (input.voiceUrl ?? '').trim();
    const voiceDurationMs = Math.max(0, Number(input.voiceDurationMs ?? 0));

    if (text.length === 0 && images.length === 0 && voiceUrl.length === 0) {
      throw new BadRequestException(
        'Message must contain text, images or voice',
      );
    }
    if (text.length > MESSAGE_TEXT_MAX) {
      throw new BadRequestException('Message text too long');
    }
    if (images.length > MESSAGE_IMAGES_MAX) {
      throw new BadRequestException('Too many images attached');
    }
    return { text, images, voiceUrl, voiceDurationMs };
  }

  async listByConversation(
    viewer: Types.ObjectId,
    args: GetMessagesArgs,
  ) {
    // Permission check first — never leak existence of unauthorized rooms.
    const exists = await this.conversationModel.exists({
      _id: args.conversationId,
      participants: viewer,
    });
    if (!exists) throw new ForbiddenException('Not a participant');

    const page = args.pagination?.page ?? PAGE_DEFAULT;
    const limit = Math.min(args.pagination?.limit ?? LIMIT_DEFAULT, 100);

    const filter = {
      conversation: args.conversationId,
      deletedFor: { $ne: viewer },
    };

    const [docs, totalDocs] = await Promise.all([
      this.model
        .find(filter)
        .sort({ createdAt: -1, _id: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('sender', 'name phone role')
        .lean(),
      this.model.countDocuments(filter),
    ]);

    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));
    return {
      payload: docs,
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

  async send(
    senderId: Types.ObjectId,
    input: SendMessageInput,
  ): Promise<Message> {
    const { text, images, voiceUrl, voiceDurationMs } =
      this.validatePayload(input);

    // Cheap rate-limit gate. Throws 429 on flood; degrades gracefully.
    await this.antiSpam.assertNotFlooding(senderId, 'sendMessage');

    const conversation = await this.conversationModel.findOne({
      _id: input.conversationId,
      participants: senderId,
    });
    if (!conversation) {
      throw new ForbiddenException('Not a participant');
    }

    // Snapshot the replied-to message for inline rendering.
    let replyToFields: Partial<Message> = {};
    if (input.replyTo) {
      const original = await this.model
        .findOne({
          _id: input.replyTo,
          conversation: conversation._id,
        })
        .populate('sender', 'name')
        .lean();
      if (original) {
        const senderRef = original.sender as
          | { _id: Types.ObjectId; name?: string }
          | Types.ObjectId
          | undefined;
        const senderName =
          senderRef && typeof senderRef === 'object' && 'name' in senderRef
            ? (senderRef as { name?: string }).name ?? ''
            : '';
        const senderObjectId =
          senderRef && typeof senderRef === 'object' && '_id' in senderRef
            ? (senderRef as { _id: Types.ObjectId })._id
            : (senderRef as Types.ObjectId | undefined) ?? null;
        replyToFields = {
          replyTo: original._id,
          replyToText: (original.text ?? '').slice(0, 200),
          replyToSenderName: senderName,
          replyToSenderId: senderObjectId,
        };
      }
    }

    // Persist the message.
    const created = await this.model.create({
      conversation: conversation._id,
      sender: senderId,
      text,
      images,
      voiceUrl,
      voiceDurationMs,
      readBy: [senderId],
      ...replyToFields,
    });

    // Update the conversation summary AND bump per-recipient unread
    // counters atomically. `$pull` un-hides the thread for anyone who
    // had soft-deleted it — getting a message brings it back.
    const inc: Record<string, number> = {};
    const recipients: Types.ObjectId[] = [];
    for (const p of conversation.participants) {
      const pid = (p as Types.ObjectId) ?? (p as { _id: Types.ObjectId })._id;
      if (!pid.equals(senderId)) {
        inc[`unreadCounts.${pid.toString()}`] = 1;
        recipients.push(pid);
      }
    }

    const summaryText =
      text.length > 0
        ? text
        : voiceUrl.length > 0
        ? '[voice]'
        : '[photo]';
    const updatedConversation = await this.conversationModel
      .findByIdAndUpdate(
        conversation._id,
        {
          $set: {
            lastMessageText: summaryText,
            lastMessageSender: senderId,
            lastMessageAt: new Date(),
          },
          $inc: inc,
          $pull: {
            hiddenFor: { $in: conversation.participants },
          },
        },
        { new: true },
      )
      .populate('participants', 'name phone role')
      .populate('part', 'name images price currency');

    // Hydrate the message we just saved so subscribers receive a
    // fully-populated payload (avoid N+1 on the mobile side).
    const populated = await this.model.findById(created._id).populate(
      'sender',
      'name phone role',
    );

    if (!populated || !updatedConversation) {
      throw new BadRequestException('Failed to persist message');
    }

    // === Realtime fan-out ===
    await Promise.all([
      // 1. Room-scoped: only subscribers of THIS conversation receive.
      this.pubSub.publish(
        TRIGGERS.MESSAGE_SENT(conversation._id.toString()),
        { messageReceived: populated.toObject() },
      ),

      // 2. Per-user fan-out: inbox row of each recipient updates live.
      ...recipients.map((rid) =>
        this.pubSub.publish(
          TRIGGERS.CONVERSATION_UPDATED(rid.toString()),
          { conversationUpdated: updatedConversation.toObject() },
        ),
      ),

      // 3. Unread badge delta (cheap to consume; replaces full fetch).
      ...recipients.map((rid) => {
        const counts =
          (updatedConversation.unreadCounts as unknown as Record<string, number>) ??
          {};
        const unread = Number(counts[rid.toString()] ?? 0);
        return this.pubSub.publish(
          TRIGGERS.UNREAD_CHANGED(rid.toString()),
          {
            unreadCountChanged: {
              conversationId: conversation._id,
              userId: rid,
              unread,
            },
          },
        );
      }),
    ]);

    // === Push notifications ===
    // Fire-and-forget: enqueue, never block the resolver on FCM.
    const sender = (populated.sender ?? {}) as UserRefLike;
    this.push.enqueueChat({
      recipientIds: recipients.map((r) => r.toString()),
      conversationId: conversation._id.toString(),
      senderId: senderId.toString(),
      senderName: sender.name ?? 'AutoRin',
      preview: text.slice(0, 200),
      hasImages: images.length > 0,
    });

    return populated;
  }

  async deleteForMe(
    viewer: Types.ObjectId,
    messageId: Types.ObjectId,
  ): Promise<boolean> {
    const res = await this.model.updateOne(
      { _id: messageId },
      { $addToSet: { deletedFor: viewer } },
    );
    return res.modifiedCount > 0;
  }

  async update(
    senderId: Types.ObjectId,
    messageId: Types.ObjectId,
    rawText: string,
  ): Promise<Message> {
    const text = rawText.trim();
    if (text.length === 0) {
      throw new BadRequestException('Message text cannot be empty');
    }
    if (text.length > MESSAGE_TEXT_MAX) {
      throw new BadRequestException('Message text too long');
    }

    const existing = await this.model.findById(messageId);
    if (!existing) {
      throw new BadRequestException('Message not found');
    }
    const senderRef =
      (existing.sender as Types.ObjectId) ??
      (existing.sender as { _id: Types.ObjectId })._id;
    if (!senderRef.equals(senderId)) {
      throw new ForbiddenException('Only the sender can edit this message');
    }
    if ((existing.images?.length ?? 0) > 0) {
      throw new BadRequestException('Image messages cannot be edited');
    }

    const populated = await this.model
      .findByIdAndUpdate(messageId, { $set: { text } }, { new: true })
      .populate('sender', 'name phone role');
    if (!populated) {
      throw new BadRequestException('Failed to update message');
    }

    const conversation = await this.conversationModel.findById(
      existing.conversation,
    );
    if (
      conversation &&
      conversation.lastMessageSender?.equals(senderId) &&
      conversation.lastMessageText === existing.text
    ) {
      await this.conversationModel.updateOne(
        { _id: conversation._id },
        { $set: { lastMessageText: text } },
      );
    }

    await this.pubSub.publish(
      TRIGGERS.MESSAGE_SENT(existing.conversation.toString()),
      { messageReceived: populated.toObject() },
    );

    return populated;
  }

  /**
   * Typing indicators are publish-only; nothing persists in Mongo.
   * The client decides display TTL (~3s) on its own.
   */
  async setTyping(viewer: Types.ObjectId, args: TypingArgs): Promise<boolean> {
    const isParticipant = await this.conversationModel.exists({
      _id: args.conversationId,
      participants: viewer,
    });
    if (!isParticipant) throw new ForbiddenException('Not a participant');

    await this.pubSub.publish(
      TRIGGERS.TYPING(args.conversationId.toString()),
      {
        typingStatus: {
          conversationId: args.conversationId,
          userId: viewer,
          isTyping: args.isTyping,
        },
      },
    );
    return true;
  }
}
