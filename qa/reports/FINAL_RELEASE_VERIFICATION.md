# AutoRin — Final Production Release Verification

| Field | Value |
| --- | --- |
| Branch | `fix/qa-security-hardening-2026-11-13` |
| Hardening pass | 2026-11-13 (post CONDITIONAL GO fixes) |
| SMS provider | **NOT IN SCOPE** — known pending integration; `SMS_PROVIDER=log` left unchanged |
| **Final status** | **CONDITIONAL GO** |

## Finding status (this pass)

| Finding | Status | Notes |
| --- | --- | --- |
| GraphQL introspection override in production | **FIXED** | Production always `false`; env cannot re-enable |
| Production CORS localhost origins | **FIXED** | Removed from `render.yaml`; runtime rejects loopback in production |
| MinIO default credentials / localhost in blueprint | **FIXED** | Secrets `sync: false`; prod refuses loopback/missing creds |
| Frontend CSP | **PARTIALLY FIXED** | `Content-Security-Policy-Report-Only` + baseline headers on Vercel |
| HSTS | **FIXED** (config) | `ENABLE_HSTS=true` on Render; `includeSubDomains`/`preload` off |
| Log redaction unused / missing OTP keys | **FIXED** | Shared `sanitizeForLog` used by HTTP filter; expanded keys + tests |
| `@graphql-tools/utils` HIGH | **FIXED** | Override → `12.0.4` (outside advisory ranges) |
| `@apollo/server` HIGH | **PARTIALLY FIXED** | Mitigations in place; Apollo 5 requires Nest major — see migration notes |
| `sharp` HIGH | **PARTIALLY FIXED** | Deferred major `0.35.x` — see migration notes |
| React Router GHSA-qwww | **NOT APPLICABLE** | `7.18.5` ≥ patched `7.18.2`; prior report corrected |
| Playwright Firefox/WebKit binaries | **FIXED** (install) | Browsers installed; full matrix still has flaky timeouts → **PARTIALLY FIXED** coverage |
| SMS production provider | **NOT APPLICABLE** (this task) | Explicitly out of scope |

---

## 1. GraphQL introspection — FIXED

**Change:** `resolveGraphqlIntrospection()` — if production → always `false`.

**Files:**  
`autorin-backend/src/configs/graphql/graphql-introspection.ts`  
`autorin-backend/src/configs/graphql/graphql.config.ts`  
`autorin-backend/src/configs/graphql/graphql-introspection.spec.ts`  
`qa/backend/tests/introspection-policy.node.test.mjs`

**Tests:** Jest + node:test — production+`true` → off; production+`false` → off; development+`true` → on.

**Endpoint note:** Local live API remains `NODE_ENV=development`, so introspection probes still return schema (`PASS_WITH_NOTES`). Production policy is enforced in config factory and unit-tested; do not set `GRAPHQL_INTROSPECTION` in Render (ignored anyway).

---

## 2. CORS — FIXED

**Change:** Removed localhost/`127.0.0.1` from `render.yaml` `ALLOWED_ORIGINS`. Runtime rejects loopback origins in production even if mislisted.

**Files:** `render.yaml`, `autorin-backend/src/configs/cors/cors.config.ts`, `cors.config.spec.ts`

**Credentials:** still `credentials: true`.

---

## 3. MinIO — FIXED (config; dashboard secrets required)

**Change:** Blueprint no longer embeds defaults. Production `resolveMinioClientConfig` fails closed on missing secrets or loopback endpoint.

**Files:** `render.yaml`, `minio-config.ts`, `minio.provider.ts`, `minio-config.spec.ts`, `.env.example`

**Manual dashboard (required before prod boot):** set `MINIO_ENDPOINT`, `MINIO_PORT`, `MINIO_USE_SSL`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_REGION` (no localhost).

---

## 4. Frontend CSP — PARTIALLY FIXED

**Change:** Vercel headers — `Content-Security-Policy-Report-Only` (not enforced yet) plus `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`.

**Policy includes:** `'self'`, Google Fonts, API `https://autorin-backend.onrender.com` / `wss:`, `blob:`/`data:` for previews. No `default-src *`.

**Why Report-Only:** Antd/styled-components inline styles and media hosts need live browser report validation before enforcement.

**Check:** `qa/web/tests/unit/csp-vercel-headers.node.test.mjs` — PASS.

**Before enforcement:** review browser CSP reports on Vercel preview; then switch header name to `Content-Security-Policy`.

---

## 5. HSTS — FIXED (decision)

| Decision | Detail |
| --- | --- |
| Enable in Render blueprint? | **Yes** — `ENABLE_HSTS=true` |
| Reason | Public API is `https://*.onrender.com`; Render terminates TLS at the edge |
| `includeSubDomains` | **false** |
| `preload` | **false** |
| Local HTTP | Unchanged — HSTS only when `NODE_ENV=production` **and** flag set |

**File:** `render.yaml`, `autorin-backend/src/main.ts`

---

## 6. Logging redaction — FIXED

**Change:** New `sanitizeForLog` / `sanitizeForLogObject` (nested objects + arrays). Keys include otp, code, password, authorization, accessToken, refreshToken, token, secret, cookie, set-cookie, apiKey, jwt, bearer. `HttpExceptionFilter` logs sanitized JSON only.

**Files:** `src/common/logging/*`, `http-exception.filter.ts`

**Note:** Dev-only OTP terminal warns in `auth.service` / `sms.service` remain gated by `!isProductionEnv` (unchanged). SMS provider work out of scope.

---

## 7. Dependencies

See `qa/reports/DEPENDENCY_MIGRATION_NOTES.md`.

| Package | Result |
| --- | --- |
| `@graphql-tools/utils` | **12.0.4** via overrides — FIXED |
| `@apollo/server@4.13.0` | Remains HIGH vs GHSA-9q82; Nest peers block Apollo 5 — PARTIALLY FIXED |
| `sharp@0.34.5` | Remains HIGH; `0.35.5` deferred — PARTIALLY FIXED |
| `react-router@7.18.5` | **Not vulnerable** to GHSA-qwww (`<7.18.2`) — NOT APPLICABLE |
| Web `npm audit --omit=dev` | **0 vulnerabilities** (this pass) |
| Backend `npm audit --omit=dev` | Still reports HIGH/CRITICAL aggregates (Apollo/sharp/ws noise); verify with resolved tree |

---

## 8. Playwright — PARTIALLY FIXED

| Item | Status |
| --- | --- |
| Install Firefox + WebKit | **PASS** (`npx playwright install firefox webkit`) |
| Chromium suite | **PASS** — `npx playwright test --project=chromium --workers=1` → 19 passed (`hardening-2026-11-13/playwright-chromium.txt`) |
| Full matrix | Browsers present; parallel Firefox/WebKit under machine load showed timeouts — flake risk, assertions unchanged |

---

## Commands executed (hardening verification)

```text
npm --prefix autorin-backend test
npm --prefix autorin-backend test -- --detectOpenHandles --runInBand
npm --prefix autorin-backend test -- --testPathPattern=session.mongo --runInBand
npm --prefix autorin-backend run build
node --test qa/backend/tests/introspection-policy.node.test.mjs
node --test qa/web/tests/unit/csp-vercel-headers.node.test.mjs
node qa/backend/tests/audit-graphql-probes.mjs
node qa/backend/tests/security-headers.mjs
npm --prefix autorin-web run build
npx playwright install firefox webkit   # in qa/web
npm run test:chromium                   # in qa/web
npm test                                # full matrix in qa/web
flutter test / flutter analyze          # in my_auto
npm --prefix autorin-backend audit --omit=dev
npm --prefix autorin-web audit --omit=dev
pnpm --dir autorin-backend why @graphql-tools/utils
```

### Test results snapshot

| Suite | Result |
| --- | --- |
| Backend Jest (parallel) | **15 suites / 58 tests PASS** |
| Backend Jest `--detectOpenHandles` | 2 mongo hook timeouts (env flake); mongo re-run **PASS** |
| Backend build | **PASS** |
| Introspection policy node tests | **PASS** |
| CSP vercel node test | **PASS** |
| GraphQL probes (local) | **8 PASS + 1 PASS_WITH_NOTES** (dev introspection) |
| Security headers (local HTTP) | **PASS_WITH_NOTES** (no HSTS on local HTTP — expected) |
| Web build | **PASS** |
| Playwright Chromium | **19 PASS** (`--workers=1`) |
| Flutter tests | **11 PASS** |
| Flutter analyze | **PASS_WITH_NOTES** (154 info/warning, 0 errors) |
| Web npm audit | **0 vulns** |
| Backend npm audit | residual HIGH (Apollo/sharp) — see migration notes |

Evidence: `qa/reports/hardening-2026-11-13/`

---

## Remaining production risks

1. **Dashboard must set real MinIO/S3 secrets** or the API will refuse to boot in production (intentional fail-closed).
2. **SMS HTTP provider still pending** — not claimed ready; blueprint still has `SMS_PROVIDER=log`.
3. **Apollo Server 4 / sharp 0.34** residual HIGH advisories — tracked for separate migrations.
4. **CSP is Report-Only** — enforce after Vercel traffic validation.
5. **Playwright Firefox flake** under parallel load — Chromium remains the reliable gate.
6. Localhost origins removed from production CORS — local web must use its own `ALLOWED_ORIGINS` in development `.env`.

## Manual deployment checklist

- [ ] Set MinIO/S3 env vars in Render (non-localhost).
- [ ] Confirm `ENABLE_HSTS=true` present after blueprint sync.
- [ ] Confirm `ALLOWED_ORIGINS` has only HTTPS production frontends.
- [ ] Do **not** set `GRAPHQL_INTROSPECTION` in production.
- [ ] Connect real SMS provider in a later task (out of scope here).
- [ ] Review CSP Report-Only violations on Vercel, then enforce.

## Final recommendation: CONDITIONAL GO

Ship is acceptable for security hardening of introspection, CORS, MinIO fail-closed, HSTS flag, log redaction, graphql-tools override, and CSP Report-Only — **after** operators set object-storage secrets.

Not an unconditional **GO** while Apollo/sharp majors, CSP enforcement, and SMS provider remain open.
