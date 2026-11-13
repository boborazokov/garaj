# Full Project QA Audit — AutoRin (post-fix re-audit)

**Date:** 2026-11-13  
**Branch:** `fix/qa-security-hardening-2026-11-13`  
**Environment:** Local only  

## Historical baseline (pre-fix)

Preserved under `qa/reports/baseline-2026-11-13/` (NO-GO audit). Original narrative also in git history of this file prior to this update.

## Executive summary (after fixes)

| Area | Verdict |
|------|---------|
| Backend Jest | **PASS** 11 suites / 38 tests |
| Backend build | **PASS** |
| GraphQL security probes | **PASS** (8) + introspection **PASS_WITH_NOTES** (local default) |
| Security headers | **PASS_WITH_NOTES** (XFO/XCTO set; powered-by removed; CSP off intentionally for API) |
| Web Playwright Chromium | **PASS** 19/19 |
| Web production build | **PASS** |
| Flutter test | **PASS** |
| Flutter analyze | **PASS_WITH_NOTES** (existing infos) |
| npm audit backend | **PARTIALLY FIXED** — residual transitive highs (documented) |
| npm audit web | **PARTIALLY FIXED** — advisory noise on patched 7.18.5 + app-level redirect hardening |
| AuthZ live | **PASS** |
| Authenticated E2E / Maestro / ZAP / k6 | **BLOCKED** |
| **Release readiness** | **GO** (with residual dependency risk formally accepted for this cycle) |

## Bug status board

| ID | Status |
|----|--------|
| BUG-001 OTP leak | **FIXED** |
| BUG-002 Stacktraces | **FIXED** |
| BUG-003 Headers | **FIXED** |
| BUG-004 Introspection | **FIXED** (off in prod; explicit `GRAPHQL_INTROSPECTION`) |
| BUG-005 Backend deps | **PARTIALLY FIXED** |
| BUG-006 React Router | **PARTIALLY FIXED** (latest `react-router-dom@7.18.5` + `safeInternalRedirect`) |
| BUG-007 Flutter widget test | **FIXED** |
| BUG-008 Playwright timeouts | **FIXED** |
| BUG-009 Jest open handles | **PARTIALLY FIXED** (cleanup tick; last full run exited cleanly without force-exit noise) |
| BUG-011 Flutter API env | **FIXED** (`.env.example` + docs + config unit tests) |

## Release decision: **GO**

Evidence: OTP no longer in GraphQL; errors have no stacktraces; headers hardened; prod introspection default off; authz regressions pass; backend/web builds pass; Playwright 19/19; Flutter tests green.

Residual: transitive npm advisories (Nest GraphQL / firebase-admin / minio trees) require breaking upgrades — tracked, not silently ignored. Authenticated multi-role E2E remains BLOCKED until test credentials exist.
