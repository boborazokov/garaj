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
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { UseAuth, UseWsAuth } from 'src/auth/useAuth';
import { PUBSUB, TRIGGERS } from 'src/pubsub';
import {
  ConversationIdArgs,
  CreateConversationArgs,
  GetConversationsArgs,
} from '../dto';
import { Conversation } from '../schema';
import { ConversationService } from '../service';
import { PaginatedConversations } from '../types';

@Resolver(() => Conversation)
export class ConversationResolver {
  constructor(
    private readonly service: ConversationService,
    @Inject(PUBSUB) private readonly pubSub: RedisPubSub,
  ) {}

  @UseAuth()
  @Query(() => PaginatedConversations)
  getConversations(
    @Args() args: GetConversationsArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.service.list(userId, args);
  }

  @UseAuth()
  @Mutation(() => Conversation)
  createConversation(
    @Args() { data }: CreateConversationArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.service.findOrCreate(userId, data);
  }

  @UseAuth()
  @Mutation(() => Conversation)
  markAsRead(
    @Args() { conversationId }: ConversationIdArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.service.markAsRead(userId, conversationId);
  }

  @UseAuth()
  @Mutation(() => Boolean)
  deleteConversationForMe(
    @Args() args: ConversationIdArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    return this.service.deleteForMe(userId, args);
  }

  // ===========================================================
  // Subscriptions (graphql-ws)
  // ===========================================================

  /**
   * Per-user fan-out of conversation list updates: new message, unread
   * bump, "deleted for me" restored, etc.
   *
   * Filtered server-side by viewer userId so each socket only receives
   * its own events. No client-side filtering needed.
   */
  @UseWsAuth()
  @Subscription(() => Conversation, {
    resolve: (payload: { conversationUpdated: Conversation }) =>
      payload.conversationUpdated,
  })
  conversationUpdated(@Context() context: ContextType) {
    const { userId } = assertAuthenticated(context);
    return this.pubSub.asyncIterator(
      TRIGGERS.CONVERSATION_UPDATED(userId.toString()),
    );
  }
}
