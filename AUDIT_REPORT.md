# Audit report

Inspection date: 2026-10-16. Scope is the existing Garaje tree: `my_auto` (Flutter), `autorin-backend` (NestJS GraphQL), `autorin-web` (admin). This file records what was verified in code and what was changed in this pass. It is not a claim that every workflow was executed against live MongoDB, MinIO, Redis, Meilisearch, Firebase, or SMS.

## P0

`@UseRole` was not applied. `extractRequiredRoles` read metadata from the class, while the decorator stores it on the prototype, so any logged-in user could call admin GraphQL fields. Fixed in `auth-guard.shared.ts` and covered by `authorization.pipeline.spec.ts`.

## P1

| Finding | Evidence | Status |
| --- | --- | --- |
| Login said whether a phone was registered (`AUTH_USER_NOT_FOUND`) before checking the password. | `auth.service.ts` `signIn` | Fixed. Unknown phones now return `AUTH_INVALID_CREDENTIALS` after a dummy bcrypt compare. |
| Password reset said whether a phone was registered. | `requestPasswordReset` | Fixed. Unknown or deleted phones get a decoy confirmation token and no SMS. A correct guess of that decoy still cannot change a password. |
| OTP attempt counters lived only in one process. | `otp-attempt.guard.ts` | Fixed for the live path. `OtpProtectionService` uses Redis `INCR`/`PEXPIRE` and `SET NX`. If Redis is down, verification fails closed with `AUTH_OTP_UNAVAILABLE`. A successful code is consumed so it cannot be replayed. The five-attempt cap is unchanged. |
| Access JWTs never expired, and `refreshSession` / `logoutSession` did not exist. | `auth.service.ts`, `auth_api.dart` | Fixed. New logins get a 15-minute access JWT (`ACCESS_TOKEN_TTL`) plus an opaque refresh token stored only as a SHA-256 hash in `auth_sessions`. Refresh rotates the hash. Reuse of an already rotated token revokes the session. Logout and logout-all revoke rows. Password reset and account deletion revoke that user's sessions. Tokens issued before this change have no `sid` and stay valid until `LEGACY_ACCESS_TOKEN_UNTIL` (default 2026-11-16T00:00:00Z), then they are rejected. |
| Role metadata was read from the class instead of the method prototype, so `@UseRole` did not restrict GraphQL fields. | `auth-guard.shared.ts` `extractRequiredRoles` | Fixed. An authenticated USER calling an ADMIN query is rejected. Covered by `authorization.pipeline.spec.ts`. |
| Product moderation was forced off on every boot, and pending plus archived listings were published. | `main.ts` | Fixed. Startup only reads the stored flag. A missing flag means moderation is on. An explicit `false` stays off across restarts. Boot no longer calls `publishListingsWithoutReview`. |
| Auth mutations used the global throttle (120/minute), which is too loose for OTP. | `security.module.ts`, `auth.resolver.ts` | Fixed with tighter `@Throttle` limits on sign-up, confirm, sign-in, and reset. |
| `/media/*` accepted any bucket name and did not reject `..`. | `minio.service.ts` `openStoragePath` | Fixed. Paths must be a known catalog bucket and must not contain `..`, `\`, NUL, or `%`. |
| Access JWTs are signed with no `expiresIn`. The Flutter client can call `refreshSession`, but the backend has no `refreshSession` or `logoutSession` resolver. | `auth.service.ts` `jwt.sign` without expiry; `auth_api.dart`; no backend matches for `refreshSession` | Superseded by the session row above. |
| There is no automated backend, Flutter, or admin test suite for authorization. | `autorin-backend` had zero `*.spec.ts` files before this pass | Partially addressed. See verification. The GraphQL suite uses the real guards and `ownerScope`. It does not boot MongoDB or the full product resolvers. |
| Product moderation is forced off on every boot. | `main.ts` calls `setProductModerationEnabled(false)` | Fixed. See the moderation row above. |

## P2

- SMS in development prints the code on the server. In production `SMS_PROVIDER` must be `http` and `SMS_HTTP_URL` must be set. The body is `{ to, message }`. There is still no vendor account in the repo, and live delivery was not tested. `correctCode` stays off when `NODE_ENV=production`. The log transport refuses to run in production.
- Payments are still not implemented.
- Meilisearch indexing, chat Redis delivery, Firebase push, Nominatim, and MapTiler were not exercised against live services in this pass.
- Account deletion anonymizes the user, archives their parts and workshops, and revokes `auth_sessions` for that user. An access JWT that is already in flight fails on the next request because the session row is revoked. Legacy tokens with no `sid` keep working until the cutoff date.
- Request address privacy, workshop timezone, and promotion expiry were not re-tested end to end here. Prior work already ranks promotions and keeps `PartInput.region` optional for old clients.

## P3

- Slider page dots on product photos remain. They are not the removed “— · —” vehicle line.
- Profile store fields, Doʻkonim, Reklamalar, ad placements, and the Telegram bot stay removed.

## Fixes in this pass

- `autorin-backend/src/modules/media/safe-media-path.ts`
- `autorin-backend/src/utils/minio/minio.service.ts`
- `autorin-backend/src/modules/auth/otp-attempt.guard.ts`
- `autorin-backend/src/modules/auth/service/auth.service.ts`
- `autorin-backend/src/modules/auth/resolver/auth.resolver.ts`
- Unit tests next to the two new modules

## Verification (2026-10-16, release pass)

- `npx tsc --noEmit --pretty false --incremental false` — exit 0
- `npx nest build` — exit 0
- `npx jest --no-coverage --forceExit` — exit 0, 9 suites, 33 tests, including Mongo `autorin_session_test`, Redis db 15, two OTP processes, and a mock SMS server
- `npm run build` in `autorin-web` — exit 0
- `flutter analyze` on the auth and GraphQL files — exit 0 (the earlier 5 info findings are gone on those paths)
- `flutter test test/auth_session_test.dart` — exit 0, 2 tests

Live SMS to a phone carrier was not sent. Compose files still run Mongo and Redis without authentication. The release APK built successfully and was not copied over `Garage-Fozil.apk`.
