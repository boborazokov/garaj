# Backend QA Report — AutoRin

**Date:** 2026-11-13  
**Target:** `http://127.0.0.1:7007` (local NestJS + GraphQL + Mongo)  
**Rules:** No production, no app source edits, no auto-fixes

## Executed suites

| Suite | Command / artifact | Result |
|-------|--------------------|--------|
| Jest unit | `npm --prefix autorin-backend test` | **PASS** — 10 suites, 35 tests |
| GraphQL audit probes | `node qa/backend/tests/audit-graphql-probes.mjs` | **FAIL** — 6 PASS, 2 FAIL, 1 PASS_WITH_NOTES |
| Public catalog probes | `node qa/backend/tests/audit-public-catalog.mjs` | **PASS_WITH_NOTES** |
| Fixture contract | `node --test qa/backend/tests/api-contract.smoke.test.mjs` | **PASS** (earlier run) |
| Nest `test:e2e` | `jest --config ./test/jest-e2e.json` | **BLOCKED** — config/dir missing |

Raw: `qa/reports/backend-jest-raw.txt`, `backend-graphql-probes.json`, `backend-public-catalog.json`

## Auth / authorization (live)

| Probe | Result | Notes |
|-------|--------|-------|
| Invalid `signIn` | **PASS** | Returns `AUTH_INVALID_CREDENTIALS` (no token) |
| `getAdminStats` no token | **PASS** | `AUTH_UNAUTHORIZED` — no data |
| `getAdminStats` forged JWT | **PASS** | Rejected |
| `adminListUsers` no token | **PASS** | Rejected |
| `getAppSettings` no token | **PASS** | Rejected |
| Public `getParts` / `getCategories` | Data returned | Expected for marketplace catalog (document as intentional) |

Unit coverage already exercises OTP protection, sessions, authorization pipeline (`authorization.pipeline.spec.ts` **PASS**).

## Bugs found

### BUG-001 — OTP `correctCode` in GraphQL `signUp` — **High**
- **Module:** Backend Auth
- **Steps:** Mutation `signUp` requesting `correctCode` on local non-prod API
- **Expected:** OTP never in API body
- **Actual:** Numeric OTP returned in `data.signUp.correctCode` (redacted)
- **Evidence:** `backend-graphql-probes.json` `signUp-otp-leak-check`; `auth.service.ts` non-prod branch; web `SIGN_UP` selects `correctCode`
- **Suggested fix:** Remove field from schema/clients; use explicit local-only flag; enforce `NODE_ENV=production` on shared hosts  
- Detail: `qa/bug-reports/BUG-001-otp-correctcode-leak.md`

### BUG-002 — Stacktrace disclosure — **High**
- **Module:** GraphQL errors
- **Steps:** Invalid sign-in or unauth admin query
- **Expected:** Code-only errors
- **Actual:** `extensions.stacktrace` with server paths; validation errors labeled `INTERNAL_ERROR`
- **Evidence:** Probes mark `exposesStacktrace: true`
- **Suggested fix:** Disable stacktraces outside debug; sanitize filter  
- Detail: `qa/bug-reports/BUG-002-graphql-stacktrace-disclosure.md`

### BUG-009 — Jest open-handle leak — **Low**
- **Actual:** “worker process has failed to exit gracefully”
- **Evidence:** Jest stdout after green run
- **Suggested fix:** `--detectOpenHandles`; unref timers / close Mongo/Redis mocks

## Gaps (not executed as PASS)

- Authenticated seller/admin CRUD against real accounts — **BLOCKED** (no approved test credentials in `QA_*` env)
- Database migration/consistency deep checks — **BLOCKED** (no isolated QA DB tooling run this session)
- Full Nest e2e HTTP suite — **BLOCKED** (missing `test/jest-e2e.json`)

## Side effect note
Audit `signUp` probe may have created a local user for phone `+998901119998`. Clean up in local Mongo if undesired (ask before destructive cleanup).

## Backend verdict
**Conditional fail for release** until BUG-001/002 addressed or accepted with documented env controls. Core RBAC rejection paths work; unit suite is healthy.
