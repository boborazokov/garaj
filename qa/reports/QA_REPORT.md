# Full Project QA Audit — AutoRin

**Date:** 2026-11-13 (local)  
**Auditor:** Full-stack QA skill orchestration  
**Environment:** Local only (`127.0.0.1:7007`, Vite `:5173`) — **not production**  
**Constraints honored:** No application source edits, no auto-fixes, no production data, results only from executed runs

## Executive summary

| Area | Verdict |
|------|---------|
| Backend unit tests | **PASS** (35/35) |
| Backend live GraphQL authz | **PASS** (rejects unauth/forged) |
| Backend security probes | **FAIL** (OTP leak + stacktraces) |
| Web Playwright Chromium | **FAIL** (16 pass / 3 flake timeouts) |
| Flutter tests | **FAIL** (8 pass / 1 stale widget test) |
| Security / deps | **FAIL** (API disclosure + npm audit) |
| Cross-platform authenticated E2E | **BLOCKED** |
| **Release readiness** | **NO-GO** |

Detail reports: `BACKEND_REPORT.md`, `WEB_REPORT.md`, `FLUTTER_REPORT.md`, `SECURITY_REPORT.md`, `INTEGRATION_REPORT.md`.

## What was executed

1. Nest Jest full unit suite  
2. Live GraphQL audit probes (auth, admin authz, introspection, signUp OTP, validation errors)  
3. Public catalog probes (`getParts`, `getCategories`, `getAdminStats`)  
4. Playwright Chromium full local suite (smoke + audit guards + network + responsive)  
5. `flutter test` + `flutter analyze`  
6. `npm audit` (web + backend, omit dev)  
7. Security header smoke  

**Not claimed as passed:** Maestro, Patrol, ZAP, k6, Firefox/WebKit, authenticated CRUD, iOS.

## Bug register

| ID | Severity | Module | Title | Status |
|----|----------|--------|-------|--------|
| BUG-001 | **High** (Crit if misconfigured) | Backend Auth | OTP `correctCode` returned by GraphQL | Open |
| BUG-002 | **High** | Backend GraphQL | Stacktraces / path disclosure in errors | Open |
| BUG-003 | Medium | Backend HTTP | Missing security headers; `X-Powered-By` | Open |
| BUG-004 | Medium | Backend GraphQL | Introspection enabled (local; risk if shipped) | Open |
| BUG-005 | **High** | Backend deps | npm audit: 42 vulns (4 critical) | Open |
| BUG-006 | **High** | Web deps | react-router advisories (2) | Open |
| BUG-007 | Medium | Flutter tests | Stale counter `widget_test.dart` fails | Open |
| BUG-008 | Medium | Web E2E | Parallel Playwright `page.goto` timeouts | Open |
| BUG-009 | Low | Backend tests | Jest open-handle force exit | Open |
| BUG-011 | Medium | Mobile config | LAN API host env drift vs web proxy | Open |

Full dossiers: `qa/bug-reports/` (BUG-001, BUG-002, BUG-007 written in full).

### Template used for each bug

Severity · Module · Reproduction · Expected · Actual · Evidence · Suggested fix — present in linked reports (no fixes applied).

## Priority findings (short)

1. **BUG-001** — Non-prod API returns plaintext OTP; web still queries `correctCode`. Dangerous if any shared host is not `NODE_ENV=production`.  
2. **BUG-002** — Auth and validation errors include stacktraces.  
3. **BUG-005/006** — Dependency advisories need planned upgrades.  
4. **BUG-007** — `flutter test` not green (template test).  
5. Authz happy path for admin APIs works without token (good).

## Coverage gaps

- Authenticated admin/moderator/seller journeys (need isolated test users)  
- Orders / products / moderation / messaging CRUD  
- DB integrity & migration tests  
- Mobile UI E2E (Maestro/Patrol)  
- Accessibility (axe) & visual baselines  
- Performance (k6) & ZAP DAST  

## widget_test.dart investigation

Confirmed **test debt**, not a production UI crash of a counter screen. `MyApp` is the marketplace shell; the test still expects Flutter-create counter widgets. See `FLUTTER_REPORT.md` + `BUG-007`.

## Release readiness assessment

### **NO-GO** for production release

**Must address or formally accept with compensating controls before go-live:**

- BUG-001 (OTP exposure path)  
- BUG-002 (stacktrace disclosure)  
- Confirm production `NODE_ENV` / introspection off / helmet headers (BUG-003/004)  
- Plan for critical npm advisories (BUG-005/006)  

**Should address before calling CI trustworthy:**

- BUG-007 (green `flutter test`)  
- Authenticated smoke for web + mobile against staging  

**Acceptable to defer with tracking:**

- BUG-008 flaky E2E under heavy parallel  
- BUG-009 Jest teardown  
- Analyzer infos  

### When to re-audit

After you approve and land fixes for BUG-001/002 (+ optional header/introspection), re-run:

```bash
node qa/backend/tests/audit-graphql-probes.mjs
npm --prefix autorin-backend test
cd qa/web && npx playwright test --project=chromium
cd my_auto && flutter test
npm --prefix qa run qa:security
```

---

*No application fixes were made. Await approval before implementing suggested remediations.*
