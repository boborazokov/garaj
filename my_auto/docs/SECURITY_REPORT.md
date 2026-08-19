# Garaj Market / My Auto — Security Report

**Status:** Partially hardened → production track (Flutter client updated; backend contract defined).  
**Scope:** Mobile (Flutter) + NestJS GraphQL API (reference spec).

---

## Executive summary

| Area | Before | After (this pass) | Backend required |
|------|--------|-------------------|------------------|
| Auth lifecycle | Single long-lived JWT in secure storage | Access + refresh model, rotation hooks, device id | **P0** implement sessions |
| Post-login races | Memory token sometimes late | `AuthCoordinator` + memory cache + barrier | — |
| TOKEN_EXPIRED | Immediate logout | Silent refresh + single retry | `refreshSession` mutation |
| Protected GraphQL | Could run without bearer | Blocked with `UNAUTHENTICATED` | — |
| WebSocket | Could connect without JWT | Gated; reconnect after refresh | WS auth on server |
| Local JSON catalog | Bundled in app | Removed (API-only) | Seed categories |
| Validation / GQL hardening | Unknown in repo | Documented + Nest reference | **P0** server |

---

## Findings (risks)

### P0 — Critical

1. **Single JWT without refresh rotation**  
   - *Risk:* Stolen token = long compromise window.  
   - *Fix:* 15m access + 30d refresh, hashed refresh in MongoDB, rotation on each refresh.

2. **Auth race after login/OTP**  
   - *Risk:* `registerDeviceToken`, chat, favorites fire before token in memory/storage.  
   - *Fix (Flutter):* `AuthCoordinator.establishSession`, memory token, `whenReady()` barrier.

3. **No server-side session revocation**  
   - *Risk:* Logout only client-side; stolen refresh still valid.  
   - *Fix:* `sessions` collection, `logoutSession`, `logoutAllDevices`, token version bump.

### P1 — High

4. **GraphQL abuse** (alias bombing, deep queries)  
   - *Fix:* alias limit, depth limit, persisted queries, cost analysis (see `docs/backend/graphql-hardening.md`).

5. **Upload pipeline**  
   - *Risk:* SVG XSS, polyglot files, malware.  
   - *Fix:* Re-encode images, SVG sanitize, quarantine bucket, AV hook.

6. **OTP brute force**  
   - *Fix:* Per-IP + per-phone rate limits, resend cooldown, CAPTCHA hook.

7. **SQLite chat cache plaintext**  
   - *Fix:* SQLCipher or `flutter_secure_storage` for sensitive fields; wipe on logout.

### P2 — Medium

8. **Mixed architecture (Provider + Bloc)** — maintainability debt.  
9. **Duplicate create-product flows** — `add` vs `create_product`.  
10. **No Sentry / structured audit logs** in production.

---

## Flutter changes (implemented)

- `lib/core/auth/auth_coordinator.dart` — lifecycle, refresh, logout hooks  
- `lib/core/auth/refresh_single_flight.dart` — **P0** mutex: one `refreshSession` under parallel TOKEN_EXPIRED  
- `lib/core/auth/auth_request_context.dart` — `auth_already_retried` prevents retry loops  
- `lib/core/auth/auth_token_store.dart` — secure persistence, device fingerprint id  
- `lib/core/auth/auth_refresh_link.dart` — TOKEN_EXPIRED → single-flight refresh → **max 1 retry**  
- `lib/core/network/websocket_recovery_service.dart` — debounced post-reconnect sync  
- `lib/features/chat/realtime/chat_realtime_recovery.dart` — inbox/room resubscribe + delta fetch  
- `lib/core/services/graphql/graphql_links.dart` — protected ops require bearer; WS gate  
- `AuthOutput` — `accessToken`, `refreshToken`, `sessionId`, `tokenVersion` (backward compatible with `token`)

---

## Backend contract (must implement)

See `docs/AUTH_FLOW.md` and `docs/backend/nestjs-auth-reference/`.

Minimum GraphQL:

- `refreshSession(refreshToken, deviceId)`  
- `logoutSession` / `logoutAllDevices`  
- Error codes: `TOKEN_EXPIRED`, `INVALID_REFRESH_TOKEN`, `SESSION_REVOKED`  
- Sign-in / confirm return `accessToken`, `refreshToken`, `sessionId`, `tokenVersion`

---

## Production checklist

- [ ] HTTPS only (TLS 1.2+)  
- [ ] Secure headers (HSTS, CSP, X-Frame-Options)  
- [ ] MongoDB + Redis auth enabled, not exposed publicly  
- [ ] Secrets in vault / CI, not in git  
- [ ] `ValidationPipe` whitelist + forbidNonWhitelisted  
- [ ] No stack traces in prod responses  
- [ ] CORS allowlist  
- [ ] JWT/OTP never logged  
- [ ] Dependency audit in CI (`npm audit`, `dart pub outdated`)

---

## Next steps

1. Deploy NestJS auth module from reference.  
2. Migrate Flutter logout UI to “this device / all devices”.  
3. Encrypt chat SQLite.  
4. Add Sentry + auth anomaly alerts.  
5. Remove legacy `addProduct` flow.
