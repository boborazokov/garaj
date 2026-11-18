# Security QA Report — post-hardening (2026-11-13)

See also: `FINAL_RELEASE_VERIFICATION.md`, `DEPENDENCY_MIGRATION_NOTES.md`.

## GraphQL

| Check | Result |
|-------|--------|
| OTP in response | **PASS** (field removed) |
| Stacktraces | **PASS** (stripped) |
| Authz unauth | **PASS** |
| Introspection | **FIXED** — always off when `NODE_ENV=production` (env cannot re-enable) |

## HTTP / deploy config

| Item | Result |
|------|--------|
| X-Powered-By | absent |
| X-Frame-Options | DENY |
| X-Content-Type-Options | nosniff |
| HSTS | `ENABLE_HSTS=true` on Render; off on local HTTP; no includeSubDomains/preload |
| API CSP | disabled on Nest (documented) |
| Web CSP | **Report-Only** on Vercel (`vercel.json`) |
| Production CORS | no localhost; loopback rejected in production |
| MinIO blueprint | no default secrets; prod fail-closed without dashboard secrets |
| Log redaction | sanitizeForLog used; includes otp/code/tokens |

## Dependency audits

| Target | Result |
|--------|--------|
| `@graphql-tools/utils` | **FIXED** → 12.0.4 override |
| Web npm omit-dev | **0 vulnerabilities** (this pass) |
| `@apollo/server` / `sharp` | residual HIGH — deferred majors (migration notes) |
| React Router GHSA-qwww | **NOT APPLICABLE** at 7.18.5 |

## Out of scope

SMS HTTP provider integration — pending; not claimed ready.

ZAP / k6: **BLOCKED** (tools not installed).
