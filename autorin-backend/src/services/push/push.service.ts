import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { Queue } from 'bullmq';
import { Types } from 'mongoose';
import { DeviceTokenService } from 'src/modules/device-token/service';
import { UserNotificationService } from 'src/modules/user-notification/service/user-notification.service';
import { FirebaseService } from './firebase.service';
import {
  ChatPushJob,
  FavoriteMatchedPushJob,
  NewFollowerPushJob,
  OrderReplyPushJob,
  PromotedExpiredPushJob,
  PushBody,
  PushJobName,
  SellerResponsePushJob,
  UserVerifiedPushJob,
} from './push.types';

/**
 * High-level push API used by feature resolvers (Message, Order, Part).
 *
 * Resolvers should NEVER call `firebase.service` directly:
 *  - We *always* enqueue, never send inline → keeps mutation latency
 *    low and isolates FCM outages from user-facing requests.
 *  - The worker, not the resolver, deactivates dead tokens.
 *
 * The queue uses BullMQ with Redis as the broker. Multiple worker
 * instances can scale horizontally without losing jobs.
 */
export const PUSH_QUEUE = 'push';

@Injectable()
export class PushService {
  private readonly logger = new Logger(PushService.name);

  constructor(
    @InjectQueue(PUSH_QUEUE) private readonly queue: Queue,
    private readonly firebase: FirebaseService,
    private readonly tokens: DeviceTokenService,
    private readonly inbox: UserNotificationService,
  ) {}

  // =========================================================
  // Public API — resolvers enqueue, never send inline.
  // =========================================================

  enqueueChat(job: ChatPushJob) {
    return this.enqueue('chat-message', job);
  }

  enqueueOrderReply(job: OrderReplyPushJob) {
    return this.enqueue('order-reply', job);
  }

  enqueueFavoriteMatched(job: FavoriteMatchedPushJob) {
    return this.enqueue('favorite-matched', job);
  }

  enqueuePromotedExpired(job: PromotedExpiredPushJob) {
    return this.enqueue('promoted-expired', job);
  }

  enqueueSellerResponse(job: SellerResponsePushJob) {
    return this.enqueue('seller-response', job);
  }

  enqueueNewFollower(job: NewFollowerPushJob) {
    return this.enqueue('new-follower', job);
  }

  enqueueUserVerified(job: UserVerifiedPushJob) {
    return this.enqueue('user-verified', job);
  }

  // =========================================================
  // Internal API — only the worker calls these.
  // =========================================================

  /**
   * Deliver a notification to every active device of the given users.
   * Returns once FCM has accepted (or definitively rejected) all
   * tokens; dead tokens are deactivated atomically.
   *
   * `data` ends up in the message payload mobile clients use for deep
   * linking (chat/:id, product detail, etc.).
   */
  async dispatch(
    userIds: string[],
    payload: PushBody,
    data: Record<string, string>,
  ): Promise<void> {
    try {
      await this.inbox.createForUsers(userIds, {
        type: data.type ?? 'unknown',
        title: payload.title,
        body: payload.body,
        deepLink: data.deepLink,
        data,
      });
    } catch (err) {
      this.logger.warn(`Failed to persist inbox notifications: ${err}`);
    }

    const oids = userIds
      .filter((u) => Types.ObjectId.isValid(u))
      .map((u) => new Types.ObjectId(u));
    const tokens = await this.tokens.activeTokensForUsers(oids);
    if (!tokens.length) return;

    if (!this.firebase.isReady()) {
      this.logger.warn(
        `Skipping push to ${tokens.length} tokens — Firebase not configured.`,
      );
      return;
    }

    const invalid = await this.firebase.sendMulticast(tokens, {
      notification: payload,
      data: {
        ...data,
        // Required by `click_action` intent filter on Android.
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'autorin_high',
          sound: 'default',
          defaultSound: true,
          // Helps Android group chat threads visually.
          tag: data.conversationId ?? undefined,
        },
      },
      apns: {
        headers: { 'apns-priority': '10' },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            // Use the modern threading API on iOS so multiple chat
            // notifications group under the same conversation.
            'thread-id': data.conversationId ?? undefined,
            'mutable-content': 1,
          },
        },
      },
    });

    if (invalid.length) {
      await this.tokens.deactivateMany(invalid);
    }
  }

  // =========================================================
  // Queue plumbing.
  // =========================================================

  private enqueue<T>(name: PushJobName, payload: T) {
    return this.queue.add(name, payload, {
      // 5 attempts → 1s, 2s, 4s, 8s, 16s exponential backoff.
      attempts: 5,
      backoff: { type: 'exponential', delay: 1000 },
      // Keep finished jobs around for short-term ops visibility,
      // but cap the retention to bound Redis memory.
      removeOnComplete: { age: 3600, count: 1000 },
      removeOnFail: { age: 86400, count: 5000 },
    });
  }
}
