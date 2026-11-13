# Cross-Platform Integration Report — AutoRin

**Date:** 2026-11-13  
**Clients:** Web (Vite/Apollo), Mobile (Flutter/graphql_flutter), API (Nest GraphQL `:7007`)

## Executed integration checks

| Check | Result | Evidence |
|-------|--------|----------|
| API GraphQL alive (`__typename`) | **PASS** | probes |
| Web → `/api` via Vite proxy (config) | **PASS** (config review + Playwright against proxied origin when Vite up) | `vite.config.ts` proxies `/api` → `127.0.0.1:7007` |
| Web unauth → API GraphQL errors handled | **PASS** | Playwright network-failure + invalid creds |
| Mobile → same GraphQL contract (`_id`, signIn) | **PASS_WITH_NOTES** | Client uses `_id`; matches schema |
| End-to-end authenticated web+mobile same user | **BLOCKED** | No shared test credentials |
| Maestro device flow vs API | **BLOCKED** | No Maestro CLI |
| Contract/Pact suite | **BLOCKED** | Not installed |

## Contract alignment

- Web `SIGN_IN` uses `user { _id name phone role }` — matches backend User GraphQL (`id` is invalid; confirmed by live validation error when probes used `id`).
- Admin ops: `getAdminStats`, `adminListUsers`, `getAppSettings` — authz enforced server-side.
- Public catalog `getParts` / `getCategories` available without token — consistent with marketplace; mobile/web can browse anonymously.

## Integration risks

### BUG-011 — Env drift (mobile LAN IP vs web proxy) — **Medium**
Mobile `.env` uses LAN host for API; web dev uses same-origin Vite proxy. Developers/devices may hit different backends or fail offline LAN.

### BUG-001 impact across clients
Any client that requests `correctCode` (web `SIGN_UP` does) will receive OTP on non-prod API — cross-client security issue.

### Session model
Flutter unit tests confirm refresh-token persistence and `accessToken`/`token` dual read — good for multi-client tokens. Live refresh rotation across web+mobile **not** executed.

## Suggested integration follow-ups (no fixes applied)

1. Shared `qa/test-data` fixtures + isolated users for admin/seller/buyer.
2. One GraphQL operations snapshot shared or codegen from schema.
3. CI job: backend up → Playwright chromium → `flutter test` (excluding or fixing BUG-007).

## Integration verdict
**Basic public + unauth integration OK on local.** Authenticated cross-platform journeys remain **BLOCKED**; env drift and OTP field are the main cross-cutting risks.
