# WebSocket authentication

## Client (Flutter)

- Transport: `graphql-ws` via `WebSocketLink`  
- URL: `ws(s)://{API_URL}/api`  
- Handshake payload:

```json
{ "authorization": "Bearer <access_jwt>" }
```

- **No token → no connection** (`WebSocketAuthGateLink`)  
- After `refreshSession` → `dispose()` socket → recreate link → `connectOrReconnect()`  
- On logout → `disconnectWebSocket()` (no anonymous subscriptions)

## Server requirements (NestJS + graphql-ws)

1. Validate JWT on `connection_init` / `onConnect`  
2. Reject missing/invalid token for protected subscriptions  
3. Heartbeat: ping every 30s, disconnect stale > 90s  
4. Limits per connection:
   - Max 20 active subscriptions  
   - Max payload 64KB  
5. Redis rate limiter for connection attempts per IP  
6. On `TOKEN_EXPIRED` close with code 4401; client refreshes HTTP then reconnects  

## Subscription auth refresh

Server should not assume WS token outlives HTTP access token (15m). Client reconnects after refresh with new Bearer in `initialPayload`.

## Flood protection

- Token bucket per IP (Redis)  
- Max 5 connection attempts / minute / IP  
- Log `HANDSHAKE_RATE_LIMITED` (client already ignores for session revoke)
