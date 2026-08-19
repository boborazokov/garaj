/**
 * Central catalog of PubSub trigger names.
 *
 * Why centralize:
 * - Subscriptions must publish & subscribe with the exact same string.
 *   A typo silently breaks realtime delivery.
 * - Room-scoped triggers (per conversation / per user) drastically
 *   reduce fan-out on the subscriber side: every client only listens
 *   to the rooms it cares about, not the global firehose.
 */
export const TRIGGERS = {
  /** Fan-out for a single conversation: only its participants subscribe. */
  MESSAGE_SENT: (conversationId: string) => `MESSAGE_SENT:${conversationId}`,

  /** Typing indicator is room-scoped, debounced on the client (3s TTL). */
  TYPING: (conversationId: string) => `TYPING:${conversationId}`,

  /**
   * Per-user conversation list updates (new message, unread bump, etc).
   * Subscribers in the inbox view listen only to their own user trigger.
   */
  CONVERSATION_UPDATED: (userId: string) => `CONV_UPDATED:${userId}`,

  /** Per-user unread counter delta; cheaper than re-fetching the whole list. */
  UNREAD_CHANGED: (userId: string) => `UNREAD_CHANGED:${userId}`,

  /** Presence (online / offline / lastSeen). */
  PRESENCE: (userId: string) => `PRESENCE:${userId}`,

  ORDER_UPDATED: (orderId: string) => `ORDER_UPDATED:${orderId}`,
  ORDER_RESPONSE_ADDED: (orderId: string) => `ORDER_RESPONSE_ADDED:${orderId}`,
};

export type TriggerName = ReturnType<(typeof TRIGGERS)[keyof typeof TRIGGERS]>;
