import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { NotificationTemplates } from './notification.templates';
import { PushService, PUSH_QUEUE } from './push.service';
import {
  ChatPushJob,
  FavoriteMatchedPushJob,
  NewFollowerPushJob,
  OrderReplyPushJob,
  PromotedExpiredPushJob,
  PushEventType,
  PushJobName,
  SellerResponsePushJob,
  UserVerifiedPushJob,
} from './push.types';

/**
 * Single BullMQ worker that processes every push job type.
 *
 * Why one worker, not one per type:
 *  - Workers consume a fixed Redis connection. Splitting by type just
 *    multiplies connections without giving us better isolation.
 *  - Concurrency is controlled by `@Processor({ concurrency })` and is
 *    plenty for FCM (which itself is the throughput bottleneck).
 *
 * Retries are configured in `PushService.enqueue`; the worker just
 * throws on failure and BullMQ does the rest.
 */
@Processor(PUSH_QUEUE, { concurrency: 10 })
export class PushWorker extends WorkerHost {
  private readonly logger = new Logger(PushWorker.name);

  constructor(private readonly push: PushService) {
    super();
  }

  async process(job: Job<unknown, unknown, PushJobName>): Promise<void> {
    switch (job.name) {
      case 'chat-message':
        return this.handleChat(job.data as ChatPushJob);
      case 'order-reply':
        return this.handleOrderReply(job.data as OrderReplyPushJob);
      case 'favorite-matched':
        return this.handleFavoriteMatched(job.data as FavoriteMatchedPushJob);
      case 'promoted-expired':
        return this.handlePromotedExpired(job.data as PromotedExpiredPushJob);
      case 'seller-response':
        return this.handleSellerResponse(job.data as SellerResponsePushJob);
      case 'new-follower':
        return this.handleNewFollower(job.data as NewFollowerPushJob);
      case 'user-verified':
        return this.handleUserVerified(job.data as UserVerifiedPushJob);
      default:
        this.logger.warn(`Unknown push job name: ${job.name as string}`);
    }
  }

  private async handleChat(d: ChatPushJob) {
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.newMessage(d.senderName, d.preview, d.hasImages),
      {
        type: PushEventType.CHAT_MESSAGE,
        conversationId: d.conversationId,
        senderId: d.senderId,
        senderName: d.senderName,
        preview: d.preview.slice(0, 200),
        deepLink: `/chat/${d.conversationId}`,
      },
    );
  }

  private async handleOrderReply(d: OrderReplyPushJob) {
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.newOrderReply(
        d.orderTitle,
        d.replierName,
        d.responsePreview,
      ),
      {
        type: PushEventType.ORDER_REPLY,
        orderId: d.orderId,
        replierName: d.replierName,
        deepLink: `/orders/${d.orderId}`,
      },
    );
  }

  private async handleFavoriteMatched(d: FavoriteMatchedPushJob) {
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.favoriteMatched(d.partName),
      {
        type: PushEventType.FAVORITE_MATCHED,
        partId: d.partId,
        deepLink: `/productDetailScreen?id=${d.partId}`,
      },
    );
  }

  private async handlePromotedExpired(d: PromotedExpiredPushJob) {
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.promotedExpired(d.partName),
      {
        type: PushEventType.PROMOTED_EXPIRED,
        partId: d.partId,
        deepLink: `/my_products`,
      },
    );
  }

  private async handleSellerResponse(d: SellerResponsePushJob) {
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.sellerResponse(d.partName, d.sellerName),
      {
        type: PushEventType.SELLER_RESPONSE,
        partId: d.partId,
        deepLink: `/productDetailScreen?id=${d.partId}`,
      },
    );
  }

  private async handleNewFollower(d: NewFollowerPushJob) {
    const sellerId = d.recipientIds[0] ?? '';
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.newFollower(d.followerName),
      {
        type: PushEventType.NEW_FOLLOWER,
        followerId: d.followerId,
        followerName: d.followerName,
        sellerId,
        deepLink: `/sellerFollowers?sellerId=${sellerId}`,
      },
    );
  }

  private async handleUserVerified(d: UserVerifiedPushJob) {
    await this.push.dispatch(
      d.recipientIds,
      NotificationTemplates.userVerified(),
      {
        type: PushEventType.USER_VERIFIED,
        userId: d.userId,
        deepLink: `/sellerProfile?sellerId=${d.userId}`,
      },
    );
  }
}
