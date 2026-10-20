# API and feature status

Status is from the current source, not from a full device pass.

| Area | Status | Where | Follow-up |
| --- | --- | --- | --- |
| Phone registration and 5-digit OTP | Partial | `auth.service.ts`, Redis OTP tests, `sms.service.spec.ts` | Five shared attempts and single-use were tested on Redis. HTTP SMS was tested against a mock server. A live gateway is not configured. |
| Login with phone and password | Implemented | `signIn` | Unknown phone and wrong password share `AUTH_INVALID_CREDENTIALS`. New sessions expire and refresh. |
| Password reset | Partial | `requestPasswordReset`, `resetPassword` | Dev SMS log only. Unknown phones get a decoy token. Success revokes sessions. |
| JWT sessions and refresh | Implemented and tested on an isolated Mongo database | `session.service.ts`, `session.mongo.spec.ts`, Flutter `auth_token_store.dart` | Legacy tokens die at 2026-11-16. New tokens expire. The previous APK still needs a rebuild to store refresh tokens. |
| Account deletion | Implemented | `user.service.ts` `deleteMyAccount` | Profile is anonymized, listings archived, sessions revoked. |
| Guest catalog | Implemented | Public product queries | Region stays optional on `PartInput` for old clients. |
| Product create, edit, archive, promote, views, share | Implemented | Part module, Flutter product flows | Feed rank is promoted-in-region, other promoted, then newer. |
| Categories (22 groups) | Implemented | `parts-categories.seed.json`, merge of retired slugs | Do not delete categories that products still reference outside that merge map. |
| Search | Partial | Meilisearch module | Not re-indexed or queried in this pass. |
| Payments and wallet | Missing | — | No provider. Do not fake a successful charge. |
| Menga kerak | Implemented | Order module | Address on the card is the region; typed address stays on the detail screen. |
| Workshops, services, bookings | Implemented | Workshop and service modules | Admin web has no workshop pages. Admin API ownership bypass exists. |
| Chat | Implemented | Chat module, Redis | Participant checks were not re-run live. |
| Push | Blocked | Firebase config | Disabled when credentials are absent. |
| Contact us | Implemented | `contactInfo` query, admin settings | Values come from app settings, with defaults only when unset. |
| Admin panel | Implemented | `autorin-web` | ADMIN can manage users, parts, requests, categories, banners, settings. MODERATOR is limited to the queue. |
| Telegram bot | Removed | `src/bot` deleted, `telegraf` uninstalled | Do not restore. |
| Media proxy | Implemented | `GET /media/*` | Path traversal and unknown buckets rejected. |
