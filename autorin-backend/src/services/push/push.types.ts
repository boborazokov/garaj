/**
 * Cross-module DTOs for the push subsystem. Lives outside resolvers to
 * avoid circular imports between Message → PushService → Message.
 */

export enum PushEventType {
  CHAT_MESSAGE = 'chat',
  ORDER_REPLY = 'orderReply',
  ORDER_MATCHED = 'orderMatched',
  FAVORITE_MATCHED = 'favoriteMatched',
  PROMOTED_EXPIRED = 'promotedExpired',
  SELLER_RESPONSE = 'sellerResponse',
  USER_VERIFIED = 'userVerified',
}

export interface ChatPushJob {
  recipientIds: string[];
  conversationId: string;
  senderId: string;
  senderName: string;
  preview: string;
  hasImages: boolean;
}

export interface OrderReplyPushJob {
  recipientIds: string[];
  orderId: string;
  orderTitle: string;
  replierName: string;
  /** Short excerpt of the seller's response text. */
  responsePreview?: string;
}

/** Buyer posted a request that matches a seller's listing categories. */
export interface OrderMatchedPushJob {
  recipientIds: string[];
  orderId: string;
  orderTitle: string;
  categoryName?: string;
  budget?: number;
  currency?: string;
}

export interface FavoriteMatchedPushJob {
  recipientIds: string[];
  partId: string;
  partName: string;
}

export interface PromotedExpiredPushJob {
  recipientIds: string[];
  partId: string;
  partName: string;
}

export interface SellerResponsePushJob {
  recipientIds: string[];
  partId: string;
  partName: string;
  sellerName: string;
}

export interface UserVerifiedPushJob {
  recipientIds: string[];
  userId: string;
}

/**
 * Strongly-typed BullMQ job name registry. BullMQ uses strings for job
 * names; the union here makes typos a compile error.
 */
export type PushJobName =
  | 'chat-message'
  | 'order-reply'
  | 'order-matched'
  | 'favorite-matched'
  | 'promoted-expired'
  | 'seller-response'
  | 'user-verified';

export interface PushBody {
  title: string;
  body: string;
}
