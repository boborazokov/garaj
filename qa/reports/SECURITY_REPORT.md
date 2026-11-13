# Security QA Report — post-fix

## GraphQL

| Check | Result |
|-------|--------|
| OTP in response | **PASS** (field removed) |
| Stacktraces | **PASS** (stripped) |
| Authz unauth | **PASS** |
| Introspection | Off when `NODE_ENV=production`; local default on unless `GRAPHQL_INTROSPECTION=false` |

## HTTP headers

| Header | Observed |
|--------|----------|
| X-Powered-By | absent |
| X-Frame-Options | DENY |
| X-Content-Type-Options | nosniff |
| HSTS | off on local HTTP (expected) |
| CSP | disabled on API (documented) |

## Dependency audits

| Target | Before | After |
|--------|--------|-------|
| Backend npm omit-dev | 42 (4 crit) | Still reports ~42 via npm; pnpm prod ~17 (0 crit in last summary) — **PARTIALLY FIXED** |
| Web npm omit-dev | 2 | Still reported; installed router 7.18.5 + redirect sanitize — **PARTIALLY FIXED** |

ZAP / k6: **BLOCKED** (tools not installed).
