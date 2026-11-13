# Security QA Report — AutoRin

**Date:** 2026-11-13  
**Scope:** Local API + dependency audits + header smoke  
**Not run:** OWASP ZAP full DAST (**BLOCKED** — tool missing), production scans (forbidden)

## Executed

| Check | Result |
|-------|--------|
| GraphQL auth rejection probes | PASS (auth) / FAIL (info disclosure) |
| OTP leak probe | **FAIL** (BUG-001) |
| Stacktrace probe | **FAIL** (BUG-002) |
| Introspection `__schema` | **PASS_WITH_NOTES** — enabled locally |
| Security headers smoke | **PASS_WITH_NOTES** |
| `npm audit` backend (omit dev) | **FAIL** — 42 vulns (4 critical, 24 high, 14 moderate) |
| `npm audit` web (omit dev) | **FAIL** — 2 vulns (react-router family) |
| ZAP | **BLOCKED** |

Artifacts: `backend-graphql-probes.json`, `npm-audit-backend.txt`, `npm-audit-web.txt`, `qa-run-security-*.md`

## Findings

### BUG-001 — OTP in GraphQL response — **High / Critical-if-misconfigured**
See `qa/bug-reports/BUG-001-otp-correctcode-leak.md`. Non-prod path returns `correctCode`; clients request it.

### BUG-002 — Stacktraces in API errors — **High**
See `qa/bug-reports/BUG-002-graphql-stacktrace-disclosure.md`.

### BUG-003 — Missing security headers — **Medium**
- **Module:** Backend HTTP
- **Steps:** `GET` API origin; observe headers
- **Expected:** At least `X-Content-Type-Options`, `X-Frame-Options`/`frame-ancestors`, CSP as appropriate; HSTS on HTTPS deploys
- **Actual:** `x-powered-by: Express`; CSP/HSTS/XFO/XCTO null in smoke
- **Evidence:** `security-headers.mjs` / security workflow output
- **Suggested fix:** Nest helmet / explicit header middleware; disable `X-Powered-By`

### BUG-004 — Introspection enabled — **Medium** (env-dependent)
- **Actual:** `__schema { queryType { name } types { name } }` succeeded on local
- **Suggested fix:** Disable introspection in staging/production Apollo config

### BUG-005 — Backend dependency vulnerabilities — **High**
- **Actual:** 42 advisories including `ws`, `websocket-driver`, transitive Nest GraphQL stack
- **Evidence:** `qa/reports/npm-audit-backend.txt`
- **Suggested fix:** Controlled `npm audit fix`; review breaking `@nestjs/graphql` upgrades; regenerate lockfile

### BUG-006 — Web `react-router` advisories — **High**
- **Actual:** Open redirect / XSS / DoS related GHSA entries on react-router 7.x range in use
- **Evidence:** `qa/reports/npm-audit-web.txt`
- **Suggested fix:** Upgrade `react-router` / `react-router-dom` per advisory; re-run Playwright

## Positive controls verified

- Unauthenticated admin GraphQL ops rejected (`AUTH_UNAUTHORIZED`)
- Invalid credentials do not return tokens
- Throttling decorators present on auth resolver (unit-level; live rate-limit soak not run)
- Mobile `.env` is gitignored (secrets not confirmed committed)

## Security verdict
**Not release-ready** until BUG-001/002 mitigated and dependency criticals reviewed. Headers/introspection are hardening items for deploy checklist.
