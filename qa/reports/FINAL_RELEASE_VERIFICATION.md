# AutoRin — Final Production Release Verification

| Field | Value |
| --- | --- |
| Branch | `fix/qa-security-hardening-2026-11-13` (`47843b8`) |
| Date (UTC) | 2026-11-13 |
| Verifier | Independent final verification (no app source changes, no commit/push) |
| **Final status** | **CONDITIONAL GO** |

## Verdict

No known **critical application** vulnerability remains in the verified code paths: GraphQL OTP leak (`correctCode`) is removed, production stack traces are disabled in Apollo formatting, and the SMS `log` transport is refused when `NODE_ENV=production`.

Release is **not** an unconditional GO because mandatory production-security and deploy-config checks below fail or are blocked, and residual HIGH dependency exposure remains.

---

## 1. OTP and logging security

| Check | Status | Evidence |
| --- | --- | --- |
| `correctCode` absent from GraphQL schema | **PASS** | `autorin-backend/schema.gql` `ConfirmationOutput` has only `token: String!` |
| `correctCode` absent from GraphQL type | **PASS** | `autorin-backend/src/modules/auth/types/confirmation.type.ts` — field is only `token` |
| `correctCode` absent from web client | **PASS** | ripgrep `autorin-web/src` — no matches |
| `correctCode` absent from Flutter client | **PASS** | ripgrep `my_auto/lib` — no matches |
| Live probe rejects `correctCode` | **PASS** | `qa/reports/backend-graphql-probes.json` → `signUp-otp-leak-check` returns `Cannot query field "correctCode" on type "ConfirmationOutput".` |
| Dev SMS logging blocked in production | **PASS** | `autorin-backend/src/utils/sms/sms.service.ts` — `production && provider !== 'http'` → `SMS_UNAVAILABLE`; unit tests assert this |
| Dev OTP server logs gated | **PASS** (prod) / residual (non-prod) | `auth.service.ts` lines 91–92 and 231 — `DEV OTP…` / `DEV password-reset OTP…` only when `!isProductionEnv`; SMS `logDevelopmentSms` only when non-prod |
| Passwords / OTPs / tokens / secrets redacted in all log paths | **FAIL** (hygiene gap) | `HttpExceptionFilter.sanitizeForLog` exists but is **never called** elsewhere; `SENSITIVE_KEYS` omits `otp`. Cleartext OTP is intentionally logged in non-production. Production path does not use those log lines when `SMS_PROVIDER=http` and `NODE_ENV=production`. |

### Commands

```text
rg correctCode autorin-backend/schema.gql autorin-web/src my_auto/lib
node qa/backend/tests/audit-graphql-probes.mjs
```

### Evidence paths

- `qa/reports/final-verification/graphql-probes.txt`
- `qa/reports/backend-graphql-probes.json`
- `autorin-backend/src/modules/auth/service/auth.service.ts`
- `autorin-backend/src/utils/sms/sms.service.ts`
- `autorin-backend/src/common/filters/http-exception.filter.ts`

---

## 2. GraphQL security

| Check | Status | Evidence |
| --- | --- | --- |
| Production stack traces disabled | **PASS** | `graphql.config.ts` — `includeStacktraceInErrorResponses: false`; `formatGraphqlError` rebuilds extensions without stack; probes show `exposesStacktrace: false` |
| Validation / auth / authz probes | **PASS** | All auth/validation probes PASS in `backend-graphql-probes.json` / `public-catalog.txt` |
| No secrets / filesystem paths in client errors (prod path) | **PASS** (code) | `formatGraphqlError` strips debug when `isProduction`; path scrubbing for Windows/Unix paths when debug allowed |
| Local running API still returns `extensions.debug` | **PASS_WITH_NOTES** | Local API is non-production; debug hints like `JWT missing or invalid` appear — expected for `NODE_ENV≠production` |
| Production introspection disabled by default | **PASS** | Default: `introspectionEnabled = !isProd` when env unset |
| Production overrides accidental `GRAPHQL_INTROSPECTION=true` | **FAIL** | `graphql.config.ts` lines 71–77: explicit `true`/`1` **enables** introspection even when `isProd` |

### Commands

```text
node qa/backend/tests/audit-graphql-probes.mjs
node qa/backend/tests/audit-public-catalog.mjs
```

### Evidence paths

- `autorin-backend/src/configs/graphql/graphql.config.ts`
- `autorin-backend/src/common/errors/format-graphql-error.ts`
- `qa/reports/final-verification/graphql-probes.txt`
- `qa/reports/final-verification/public-catalog.txt`
- `qa/reports/backend-graphql-probes.json`

**Required mitigation before unconditional GO:** force `introspection: false` whenever `isProductionEnv`, ignoring `GRAPHQL_INTROSPECTION`.

---

## 3. HTTP security

| Check | Status | Evidence |
| --- | --- | --- |
| `X-Frame-Options: DENY` | **PASS** | Live `/health` headers |
| `X-Content-Type-Options: nosniff` | **PASS** | Live `/health` headers |
| `Referrer-Policy: no-referrer` | **PASS** | Live `/health` headers |
| `Cross-Origin-Resource-Policy: cross-origin` | **PASS** | Live `/health` headers |
| No `X-Powered-By` | **PASS** | Header empty / null; `hidePoweredBy` + Express `disable('x-powered-by')` in `main.ts` |
| HSTS on HTTPS | **PASS_WITH_NOTES** | HSTS only when `NODE_ENV=production` **and** `ENABLE_HSTS=true|1`. Local HTTP correctly has no HSTS. `render.yaml` does **not** set `ENABLE_HSTS`. |
| CSP on API process | **PASS** (intentional off) | `main.ts` comment + `contentSecurityPolicy: false` — API/GraphQL/CORS/uploads must not be constrained by browser CSP |
| Frontend CSP | **FAIL** | `autorin-web/vercel.json` has rewrites only — **no** CSP (or other security) headers; no Helmet/CSP in web app |

### Why CSP is disabled on the API

Nest serves GraphQL, multipart uploads, and cross-origin clients. Browser CSP on an API origin does not meaningfully protect the SPA/admin and can break legitimate clients. CSP belongs on the **frontend origin** (Vercel). That frontend CSP is currently missing.

### Commands

```text
node qa/backend/tests/security-headers.mjs
# plus manual header dump against http://127.0.0.1:7007/health
```

### Evidence paths

- `qa/reports/final-verification/security-headers.txt`
- `autorin-backend/src/main.ts`
- `autorin-web/vercel.json`

---

## 4. Dependency security

### Commands

```text
npm --prefix autorin-backend audit --omit=dev
npm --prefix autorin-web audit --omit=dev
pnpm --dir autorin-backend why ws
```

### Evidence paths

- `qa/reports/final-verification/npm-audit-backend.json`
- `qa/reports/final-verification/npm-audit-web.json`

### Audit summary (raw npm)

| Target | Critical | High | Moderate | Total |
| --- | --- | --- | --- | --- |
| Backend (`--omit=dev`) | 4 | 24 | 14 | 42 |
| Web (`--omit=dev`) | 0 | 1 | 1 | 2 |

### pnpm `ws` override

| Item | Result |
| --- | --- |
| Override | `autorin-backend/package.json` → `"overrides": { "ws": "8.23.0" }` |
| Resolved tree | `pnpm why ws` → all paths `ws@8.23.0` (`@nestjs/graphql`, `graphql-ws`, `subscriptions-transport-ws`) |
| Lockfile | `autorin-backend/pnpm-lock.yaml` → `ws@8.23.0` |
| npm audit still lists `ws` | Yes (range noise / parent package advisories) |
| Installed actually vulnerable? | **No** for GHSA-58qx (`<8.20.1`) and GHSA-96hv (`<8.21.0`) — **8.23.0 is outside both ranges** |

### Critical advisories — installed vs vulnerable

| Package | Installed | Direct? | Advisory | Affected range | Actually vulnerable? | Patched | Mitigation / risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `mongoose` | **8.24.9** | Direct | GHSA-6972-9mcm-vhwj | `>=8.0.0 <8.24.7` | **No** | ≥8.24.7 | None required for this advisory |
| `proxy-addr` | **2.0.8** | Transitive | GHSA-jqcg-44mw-7w3h | `>=1.1.0 <2.0.8` | **No** | ≥2.0.8 | None required for this advisory |
| `websocket-driver` | **0.7.5** | Transitive | GHSA-mp7j-qc5w-4988, GHSA-xv26-6w52-cph6 | `<0.7.5` | **No** | ≥0.7.5 | None required for these advisories |

### High advisories with confirmed residual exposure (non-exhaustive; npm reports many transitive echoes)

| Package | Installed | Direct? | Advisory | Affected range | Actually vulnerable? | Patched available | Mitigation | Remaining risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `@apollo/server` | **4.13.0** | Direct | GHSA-9q82-xgwf-vj6h | `<5.5.0` | **Yes** | 5.5.2 (major) | `csrfPrevention: true` already set; plan Apollo 5 + Nest driver upgrade | XS-Search / read-only CSRF class risk until major upgrade |
| `@graphql-tools/utils` | **12.0.0** (also 9.2.1, 8.9.0) | Transitive via `@nestjs/graphql` | GHSA-7mx3-vvmw-hjmv, GHSA-c4qx-w738-7hr3 | `<=12.0.0` / `>=10.10.1 <=12.0.1` | **Yes** (12.0.0) | Upstream Nest/GraphQL bump (no clean non-breaking fix in audit) | Track Nest GraphQL upgrade; avoid untrusted mergeDeep inputs | Prototype pollution in GraphQL tooling utilities |
| `sharp` | **0.34.5** | Direct | GHSA-f88m-g3jw-g9cj, GHSA-rgj7-g3m4-5g8c, GHSA-wq5f-xc86-pv6w | `<0.35.0` / `<0.35.4` / `<0.35.5` | **Yes** | 0.35.5 (major) | Restrict upload content types/size; schedule sharp major bump | Image codec CVEs on uploaded media processing |
| `ws` | **8.23.0** | Override / transitive | GHSA-58qx, GHSA-96hv | `<8.20.1` / `<8.21.0` | **No** | 8.23.0 installed | Override verified | Audit noise only |
| `axios` | **1.21.1** | Direct | multiple GHSA ` <1.15.x` | mostly `<1.15.1`/`<1.15.2` | **No** for listed ranges | N/A (already newer) | Keep current | Audit range metadata still lists package |
| `multer` | **2.5.0** | Transitive | several DoS GHSAs | mostly `<2.3.0` / `<2.5.0` | **No** for listed | ≥2.5.0 | Keep current | Low for listed advisories |
| `@fastify/busboy` | **3.2.5** | Transitive | GHSA-xjh9 / x8mw / gxm5 | `<3.2.1` / `<3.2.2` | **No** | ≥3.2.2 | Keep current | None for listed |
| `@grpc/grpc-js` | **1.14.7** | Transitive | GHSA-5375 / 99f4 / m9gg / f596 | `<1.14.4` / `<1.14.5` | **No** | ≥1.14.5 | Keep current | None for listed |
| `protobufjs` | **7.6.6** | Transitive | GHSA-wcpc / f38q / j3f2 | `<=7.6.0` / `<=7.6.2` / `<=7.6.4` | **No** | already > ranges | Keep current | None for listed |
| `react-router` | **7.18.5** | Via `react-router-dom` direct | GHSA-wrjc / h8fp / 337j / chx6 | mostly `<7.18.0` | **No** for those | — | Open-redirect already hardened in app (`safe-redirect`) | — |
| `react-router` | **7.18.5** | Via `react-router-dom` | GHSA-qwww-vcr4-c8h2 | `>=7.12.0 <7.18.2` | **Yes** (version in range) | ≥7.18.2 | AutoRin admin is a Vite SPA, not React Router RSC mode — practical exploitability limited; bump to ≥7.18.2 | Residual if RSC features ever enabled |

**Note:** Advisories are not classified as false positives without version-range evidence. Where installed version is outside the affected range, status is “not actually vulnerable” with that evidence.

---

## 5. Jest lifecycle

| Check | Status | Evidence |
| --- | --- | --- |
| Backend tests without `--forceExit` | **PASS** | `npm --prefix autorin-backend test` → 11 suites / 38 tests, **exit 0**, process ended |
| `--detectOpenHandles` | **PASS** | `jest --detectOpenHandles --runInBand` → 38 passed, **exit 0**, elapsed ~33s, no open-handle report printed |
| Natural exit (no added delay as proof) | **PASS** | Both runs terminated with exit code 0 without forceExit |

### Commands

```text
npm --prefix autorin-backend test
npm --prefix autorin-backend test -- --detectOpenHandles --runInBand
```

### Evidence paths

- `qa/reports/final-verification/backend-jest.txt`
- `qa/reports/final-verification/jest-detect-open-handles.txt`

---

## 6. Regression verification

| Suite | Status | Command | Evidence |
| --- | --- | --- | --- |
| Backend Jest | **PASS** | `npm --prefix autorin-backend test` | `final-verification/backend-jest.txt` |
| Backend build | **PASS** | `npm --prefix autorin-backend run build` | `final-verification/backend-build.txt` |
| GraphQL security probes | **PASS** (local introspection noted) | `node qa/backend/tests/audit-graphql-probes.mjs` | `final-verification/graphql-probes.txt` |
| Security headers | **PASS_WITH_NOTES** | `node qa/backend/tests/security-headers.mjs` | `final-verification/security-headers.txt` |
| Web Playwright (full matrix) | **BLOCKED** | `npm test` in `qa/web` | Firefox/WebKit/mobile-Safari missing browser binaries (`Executable doesn't exist … firefox-1572` / webkit). **38 passed** (Chromium + mobile-chrome), **57 failed** env-only |
| Web Playwright (Chromium) | **PASS** | `npm run test:chromium` in `qa/web` | `final-verification/playwright-chromium.txt` — exit 0 |
| Web production build | **PASS** | `npm --prefix autorin-web run build` | `final-verification/web-build.txt` |
| Flutter tests | **PASS** | `flutter test` in `my_auto` | `final-verification/flutter-test.txt` — 11 passed |
| Flutter analyzer | **PASS_WITH_NOTES** | `flutter analyze` | `final-verification/flutter-analyze.txt` — 154 issues, **0 `error`**, warnings/infos only; exit 1 from analyzer severity policy |

Assertions were not weakened; failing Firefox/WebKit runs were not skipped — they are reported as **BLOCKED** (tooling), not PASS.

---

## 7. Production configuration

Inspected: `render.yaml`, `autorin-backend/.env.example`, `autorin-web/.env.production`, `autorin-web/vercel.json`.  
**No production secret values printed.**

| Variable / topic | Configured safely? | Notes |
| --- | --- | --- |
| `NODE_ENV` | **Yes** in blueprint | `render.yaml` → `production` |
| `GRAPHQL_INTROSPECTION` | **Yes (unset = off)** / **code risk** | Not set in `render.yaml` (defaults off). Code still allows accidental `true` in production (**FAIL** in §2) |
| `ENABLE_HSTS` | **Not set** | HSTS remains off until explicitly enabled behind HTTPS |
| SMS provider | **Unsafe in blueprint** | `render.yaml` sets `SMS_PROVIDER=log` with `NODE_ENV=production`. Runtime **refuses** log transport → OTP SMS fails (`SMS_UNAVAILABLE`). Must set `SMS_PROVIDER=http` + `SMS_HTTP_URL` (+ token) before real deploy |
| API URL (web) | **Configured** | `autorin-web/.env.production` points `VITE_API_URL` / `VITE_FILE_URL` at Render host (value presence verified; not re-printed beyond public hostname pattern already in repo) |
| CORS / `ALLOWED_ORIGINS` | **Partial risk** | Blueprint includes production Vercel origins **and** `localhost` / `127.0.0.1` — overly permissive for production |
| Required secrets (`JWT_SECRET`, `DATABASE_URL`, Redis) | **sync: false** | Present as required dashboard secrets — good. Values not inspected |
| MinIO credentials in blueprint | **Unsafe defaults committed** | `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` set to well-known defaults in `render.yaml`; endpoint `localhost` unsuitable for real object storage on Render free web |

---

## 8. Remaining risks summary

### Remaining vulnerabilities (actually in range)

1. `@apollo/server@4.13.0` — GHSA-9q82 (HIGH) — needs major upgrade path.
2. `@graphql-tools/utils@12.0.0` — GHSA-7mx3 / GHSA-c4qx (HIGH) — transitive; Nest GraphQL upgrade.
3. `sharp@0.34.5` — multiple libvips/libheif/librsvg GHSAs (HIGH) — major bump.
4. `react-router@7.18.5` — GHSA-qwww (HIGH, RSC CSRF) — bump ≥7.18.2; low practical risk for current SPA.

### Remaining operational / config risks

1. **`render.yaml` `SMS_PROVIDER=log` under production** — auth SMS broken until fixed to `http`.
2. **Introspection can be forced on in production via env** — must hard-disable or ops-lock env.
3. **No frontend CSP** on Vercel.
4. **`ENABLE_HSTS` unset** — enable only after confirming HTTPS terminator.
5. **Localhost origins in production CORS list**.
6. **Default MinIO credentials in blueprint**.
7. **Playwright Firefox/WebKit browsers not installed** — cross-browser E2E **BLOCKED**.
8. **Log redaction helper unused**; non-prod still prints OTPs (acceptable only for local/dev).

### BLOCKED checks (not hidden as PASS)

- Full Playwright matrix (Firefox / WebKit / mobile-Safari binaries missing).
- Live production HTTPS HSTS observation (local HTTP only; config reviewed instead).
- Newman / k6 / Maestro / ZAP — not re-run in this pass (historically BLOCKED / optional); not claimed PASS.

---

## Final status: CONDITIONAL GO

**CONDITIONAL GO** — no known critical *application* vulnerability remains in the verified OTP/GraphQL error-handling paths, but the following require explicit approval or fix before production cutover:

1. Fix `render.yaml` SMS to `http` (+ URL/token) or equivalent dashboard override; do not ship with `SMS_PROVIDER=log` in production.
2. Accept or fix production introspection override gap (`GRAPHQL_INTROSPECTION=true` still wins).
3. Accept residual HIGH dependency exposure (`@apollo/server`, `@graphql-tools/utils`, `sharp`, `react-router` RSC advisory) or schedule patches.
4. Add frontend CSP (and preferably enable HSTS) on the public web origin.
5. Acknowledge Playwright Firefox/WebKit **BLOCKED** (Chromium suite PASS).

Until (1) and (2) are resolved or formally accepted by owners, treat deploy as conditional — not an unconditional **GO**.
