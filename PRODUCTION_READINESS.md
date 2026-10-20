# Production readiness

The app can keep running in the current development setup. It is not a locked-down production deployment.

## Release verification (2026-10-16)

Verified in this pass:

- Legacy access tokens without `sid` and without `exp` work only while the clock is strictly before `2026-11-16T00:00:00.000Z`. That instant and later are rejected. New access tokens always include `exp`. Malformed and already expired JWTs fail verification. After the cutoff everyone with an old token must log in again. Do not extend the cutoff to keep non-expiring tokens.
- Flutter writes the refresh token to secure storage and to the session JSON. Logout clears both and revokes the server session. Password reset revokes every session for that user and clears the phone. Account deletion revokes sessions and then logs out. One refresh runs at a time. An expired request is retried once.
- The 15-second grace window returns `AUTH_REFRESH_CONFLICT` for a second use of the same refresh token and does not revoke the winner. The second caller does not get a new refresh token, because the server stores only a hash. After 15 seconds that old token returns `SESSION_REVOKED` and kills the session, including the winner. That stops a stolen token from staying valid, and it also logs out the legitimate device if the stolen token is replayed after the window.
- Redis on `127.0.0.1:6379`, database 15: five failures block a second client, the count survives a new connection, a used code cannot be reused, and two OS processes share one counter. That database was flushed. It is not the application cache database.
- SMS against a local HTTP server: one POST, JSON `{ to, message }`, bearer header, no retry. HTTP 400 and a timeout fail the call. `SMS_PROVIDER=log` in production throws and does not print the code. No real SMS gateway was called.
- Mongo database `autorin_session_test` only (dropped at the start of the test): parallel refresh, expired refresh, reuse after the grace window, a new service instance still seeing the session, and revoke-all. The `autorin` database was not modified.
- Moderation: a missing flag means on. A stored `false` stays off. Startup does not publish pending or archived listings.

## Infrastructure found in the compose files

These are the local containers, not a production host.

- Mongo starts with `--noauth` and publishes port 27017.
- Redis has no password and publishes 6379. Persistence is AOF.
- Meilisearch publishes 7700, uses `MEILI_ENV=development`, and the compose file falls back to master key `autorin_master_key` when the variable is empty.
- MinIO publishes the API port and the console port.
- The repo has no TLS reverse proxy. Tracked env content is `autorin-backend/.env.example` only.

## Rollback

Deploy the previous API. Leave `auth_sessions` or drop only that collection after clients are on the old build. Tokens from this build expire in 15 minutes. Tokens from before sessions keep working until 2026-11-16.

## Commands run

- `npx tsc --noEmit --pretty false --incremental false` — exit 0
- `npx nest build` — exit 0
- `npx jest --no-coverage --forceExit` — exit 0, 9 suites, 33 tests
- `npm run build` in `autorin-web` — exit 0
- `dart format` on the touched Flutter files — exit 0
- `flutter analyze` on auth, GraphQL services, and the reset screen — exit 0
- `flutter test test/auth_session_test.dart` — exit 0, 2 tests
- `flutter build apk --release` — exit 0, `my_auto/build/app/outputs/flutter-apk/app-release.apk` (78.5MB). Gradle warned that Gradle 8.14.3, Android Gradle Plugin 8.11.1, and Kotlin 2.2.20 will soon be unsupported. `Garage-Fozil.apk` was not replaced.

## Still blocked

- A real SMS send. Set `SMS_HTTP_URL` and register from a handset.
- HTTPS and authenticated Mongo, Redis, Meilisearch, and MinIO.
- Installing the new APK and waiting 15 minutes to watch a refresh. The previous APK does not store a refresh token.

## Blockers before a public production launch

1. Set `NODE_ENV=production`. OTP `correctCode` and GraphQL `debug` stay off. Set `SMS_PROVIDER=http` and `SMS_HTTP_URL` to a gateway you control. The API posts JSON `{ "to", "message" }` and sends `Authorization: Bearer` when `SMS_HTTP_TOKEN` is set. Without that, registration and password reset return `SMS_UNAVAILABLE`. Login with an existing password still works. Do not set `SMS_PROVIDER=log` in production; the process refuses it.
2. Redis must be up for OTP attempt limits. If it is down, code checks fail closed (`AUTH_OTP_UNAVAILABLE`). They do not fall open.
3. Deploy the session change in this order: ship the API, keep `LEGACY_ACCESS_TOKEN_UNTIL` at `2026-11-16T00:00:00.000Z` (or a later date you choose), then ship the Flutter and admin builds that store `refreshToken`. Old access tokens with no expiry keep working until that cutoff. New logins receive a 15-minute access token. The current APK does not store a refresh token, so a login after this API deploy lasts 15 minutes and then returns to the login screen. After the cutoff, those old tokens stop working and everyone logs in again. Do not leave non-expiring tokens in place past the cutoff.
4. MongoDB creates `auth_sessions` on first login. No manual migration. Rollback: stop issuing new sessions by reverting the API, and drop `auth_sessions` only if you are sure no client depends on it. Existing users with legacy tokens are unaffected until the cutoff.
5. Product moderation is no longer forced off at startup. The value already stored in `app_settings` is kept. A brand-new database defaults to moderation on. Turning moderation off does not auto-publish pending or archived listings.
6. Serve the API over HTTPS on a stable host. The ngrok URL in `my_auto/.env` is not a production endpoint.
7. Turn on MongoDB, Redis, and Meilisearch authentication. Do not expose MinIO admin ports or the Meilisearch master key.
8. Add Firebase credentials only if push is required.
9. Payments are out of scope. Do not enable a fake success path.

## Manual checks still required

- Register on a handset once `SMS_HTTP_URL` answers.
- Log in, wait for the access token to expire, and confirm the app refreshes once.
- Call `refreshSession` twice with the same refresh token. The second call must be `SESSION_REVOKED` after the 15-second grace window.
- Log out, then confirm the old refresh token no longer works.
- Reset a password and confirm the previous session no longer authorizes requests.
- As a USER, call an admin settings mutation and confirm it is rejected.
- Restart the API and confirm `productModerationEnabled` is unchanged.
- Log in with a wrong password and with an unknown phone; both should look the same.
- Request a reset for an unknown phone; the API should still return a token and must not print a code for that phone.
- Open another user's product, request, and chat as a normal user and confirm the API rejects the mutation.
- Confirm an admin JWT can moderate and a moderator JWT cannot change roles.

## Environment

Use placeholders only. Real values stay in untracked env files.

Backend (`autorin-backend`, development file `.env.development`):

- `PORT` (7007)
- `DATABASE_URL`
- `JWT_SECRET` (long random value; rotating it logs everyone out)
- `MINIO_ENDPOINT`, `MINIO_PORT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_URL`
- `MEILI_HOST`, `MEILI_MASTER_KEY`
- `REDIS_HOST`, `REDIS_PORT`
- `NODE_ENV`
- `ACCESS_TOKEN_TTL` (default `15m`), `REFRESH_TOKEN_TTL_MS`, `LEGACY_ACCESS_TOKEN_UNTIL`
- `SMS_PROVIDER` (`log` only in development, `http` in production), `SMS_HTTP_URL`, `SMS_HTTP_TOKEN`

Mobile (`my_auto/.env`):

- `API_URL`, `API_File_URL` (same public API host; media is `/media/...` on that host)
- `API_GEOCODE_URL`, `MAPTILER_API_KEY`

Do not commit those files.
