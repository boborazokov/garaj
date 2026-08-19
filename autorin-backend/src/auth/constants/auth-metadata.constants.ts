/** Marks a resolver/controller handler as publicly accessible (no JWT). */
export const IS_PUBLIC_KEY = 'auth:isPublic';

/** Attaches user from Bearer when present; never rejects (browse + personalization). */
export const IS_OPTIONAL_AUTH_KEY = 'auth:optional';

/**
 * GraphQL Subscription over WebSocket: identity comes from WS handshake
 * (`onConnect`), not HTTP Authorization — validated by {@link WsAuthGuard}.
 */
export const WS_SUBSCRIPTION_AUTH_KEY = 'auth:wsSubscription';
