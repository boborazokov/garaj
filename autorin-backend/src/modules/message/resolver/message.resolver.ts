import { Inject } from '@nestjs/common';
import {
  Args,
  Context,
  Mutation,
  Query,
  Resolver,
  Subscription,
} from '@nestjs/graphql';
import type { RedisPubSub } from 'graphql-redis-subscriptions';
import { Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { UseAuth, UseWsAuth } from 'src/auth/useAuth';
import { ObjectIdScalar } from 'src/common';
import { ConversationService } from 'src/modules/conversation/service';
import { PUBSUB, TRIGGERS } from 'src/pubsub';
import {
  GetMessagesArgs,
  SendMessageArgs,
  TypingArgs,
  UpdateMessageArgs,
} from '../dto';
import { Message } from '../schema';
import { MessageService } from '../service';
import {
  PaginatedMessages,
  TypingEvent,
  UnreadCountEvent,
} from '../types';

@Resolver(() => Message)
export class MessageResolver {
  constructor(
    private readonly messages: MessageService,
    private readonly conversations: ConversationService,
    @Inject(PUBSUB) private readonly pubSub: RedisPubSub,
  ) {}

  // ============================================================
  // Queries / Mutations (HTTP)
  // ============================================================

  @UseAuth()
  @Query(() => PaginatedMessages)
  getMessages(
    @Args() args: GetMessagesArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.messages.listByConversation(userId, args);
  }

  @UseAuth()
  @Mutation(() => Message)
  sendMessage(
    @Args() { data }: SendMessageArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.messages.send(userId, data);
  }

  @UseAuth()
  @Mutation(() => Boolean)
  deleteMessageForMe(
    @Args('messageId', { type: () => ObjectIdScalar })
    messageId: Types.ObjectId,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.messages.deleteForMe(userId, messageId);
  }

  @UseAuth()
  @Mutation(() => Message)
  updateMessage(
    @Args() { data }: UpdateMessageArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.messages.update(userId, data.messageId, data.text);
  }

  @UseAuth()
  @Mutation(() => Boolean)
  setTyping(
    @Args() args: TypingArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.messages.setTyping(userId, args);
  }

  // ============================================================
  // Subscriptions (WebSocket)
  // ============================================================

  /**
   * Fan-out for ONE conversation. We assert membership BEFORE handing
   * out the async iterator — bad clients can't sniff strangers' rooms
   * even by spamming subscriptions.
   */
  @UseWsAuth()
  @Subscription(() => Message, {
    resolve: (payload: { messageReceived: Message }) => payload.messageReceived,
  })
  async messageReceived(
    @Args('conversationId', { type: () => ObjectIdScalar })
    conversationId: Types.ObjectId,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    await this.conversations.assertParticipant(userId, conversationId);
    return this.pubSub.asyncIterator(
      TRIGGERS.MESSAGE_SENT(conversationId.toString()),
    );
  }

  @UseWsAuth()
  @Subscription(() => TypingEvent, {
    resolve: (payload: { typingStatus: TypingEvent }) => payload.typingStatus,
    filter: (
      payload: { typingStatus: TypingEvent },
      _vars: Record<string, unknown>,
      context: ContextType,
    ) =>
      // Echo suppression: don't notify yourself.
      payload.typingStatus.userId.toString() !==
        assertAuthenticated(context).userId.toString(),
  })
  async typingStatus(
    @Args('conversationId', { type: () => ObjectIdScalar })
    conversationId: Types.ObjectId,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    await this.conversations.assertParticipant(userId, conversationId);
    return this.pubSub.asyncIterator(
      TRIGGERS.TYPING(conversationId.toString()),
    );
  }

  /**
   * Per-user unread counter pulses. The inbox badge subscribes here
   * without resubscribing per-conversation.
   */
  @UseWsAuth()
  @Subscription(() => UnreadCountEvent, {
    resolve: (payload: { unreadCountChanged: UnreadCountEvent }) =>
      payload.unreadCountChanged,
  })
  unreadCountChanged(@Context() context: ContextType) {
    const { userId } = assertAuthenticated(context);
    return this.pubSub.asyncIterator(TRIGGERS.UNREAD_CHANGED(userId.toString()));
  }
}
