# Phase A — Repository inspection & baseline (pre-fix)

**Recorded:** 2026-11-13  
**Branch at inspection:** `main` (ahead of `origin/main` by 1: `47843b8 fix issue`)  
**Working tree dirty (unrelated):** `graphify-out/cache/last_query_stamp` only  
**Source modifications in Phase A:** none

## Git / risk notes

- QA harness, Cursor skills, and prior audit reports are already tracked in the local ahead commit (`fix issue`).
- No unrelated user app WIP detected beyond the graphify cache stamp.
- Dedicated fix branch to be created from current `HEAD` before Phase B: `fix/qa-security-hardening-2026-11-13`.

## Services at baseline

| Service | Status |
|---------|--------|
| Backend `http://127.0.0.1:7007/health` | UP |
| Web `http://127.0.0.1:5173` | DOWN (Playwright can use `QA_START_WEB=1`) |

## Baseline test results (executed)

| Suite | Command | Result | Evidence |
|-------|---------|--------|----------|
| Backend Jest | `npm --prefix autorin-backend test` | **PASS** 10 suites / 35 tests | `backend-jest.txt` |
| GraphQL security probes | `node qa/backend/tests/audit-graphql-probes.mjs` | **FAIL** 6 PASS / 2 FAIL / 1 PASS_WITH_NOTES | `graphql-probes.txt`, `backend-graphql-probes.json` |
| Security headers | `node qa/backend/tests/security-headers.mjs` | **PASS_WITH_NOTES** (`X-Powered-By: Express`, no CSP/XFO/XCTO/HSTS) | `security-headers.txt` |
| npm audit backend | `npm --prefix autorin-backend audit --omit=dev` | **FAIL** 42 (4 critical, 24 high, 14 moderate) | `npm-audit-backend.txt` |
| npm audit web | `npm --prefix autorin-web audit --omit=dev` | **FAIL** 2 (react-router family) | `npm-audit-web.txt` |
| Flutter test | `flutter test` | **FAIL** 8 pass / 1 fail (`widget_test.dart`) | `flutter-test.txt` |

## Root-cause map (from source inspection)

| Bug | Primary files | Cause |
|-----|---------------|-------|
| BUG-001 | `auth.service.ts`, `confirmation.type.ts`, `schema.gql`, web `operations.ts`, Flutter `auth_api.dart` / `sign_up_provider.dart` / `confirmation_screen.dart` / `app_router.dart` / `reset_password_screen.dart` | `@Field correctCode` + non-prod assignment; clients select & use it |
| BUG-002 | `format-graphql-error.ts`, Apollo default extensions | Spreads `formattedError.extensions` (keeps Apollo `stacktrace`); validation → `INTERNAL_ERROR` via GraphQLError path |
| BUG-003 | `main.ts` | No Helmet; Express default `X-Powered-By` |
| BUG-004 | `graphql.config.ts` `introspection: !isProd` | Off in prod already; local always on — need explicit opt-in flag |
| BUG-005 | backend lockfile / `ws` / Nest GraphQL tree | Transitive advisories; force-fix would break Nest major |
| BUG-006 | `react-router` / `react-router-dom` | Installed ~7.18.5 but audit still flags; extraneous `react-router@7.16.0`; need clean bump past advisory ranges |
| BUG-007 | `my_auto/test/widget_test.dart` | Flutter create counter template |
| BUG-008 | `qa/web` Playwright | Parallel `page.goto` load timeouts (prior audit) |
| BUG-009 | Jest suite | Open-handle force-exit warning historically |
| BUG-011 | `my_auto/.env` (gitignored), no `.env.example` | LAN IP drift; no documented placeholders |

## Planned Phase B entry points (no edits yet)

1. Remove `correctCode` from GraphQL type + services + all clients; keep OTP verify paths.
2. Strip `stacktrace`/`debug` from client errors unless explicit local debug; map GraphQL validation to safe code.
