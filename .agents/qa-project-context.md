# AutoRin — QA Project Context

> Generated during QA environment installation. Evidence-based; unknowns labeled.
> Every QA skill should read this file first.

## Product

- **Name:** AutoRin (repo: Garaje)
- **Type:** Marketplace for automobile parts, accessories, and related technical goods
- **Clients:** Admin/moderator web (`autorin-web`), NestJS API (`autorin-backend`), Flutter mobile (`my_auto`)
- **Local URLs (dev):**
  - Web: `http://127.0.0.1:5173`
  - API / GraphQL: `http://127.0.0.1:7007/api`
- **Production URLs:** Do not test without explicit permission
- **Critical journeys:** Sign-in (admin/moderator), product/listing moderation, orders, messages, categories, workshops, user management, mobile buyer browse/order/auth

## Tech Stack

| Layer | Stack | Source |
|-------|-------|--------|
| Web | React 19, Vite 8, Apollo Client, Ant Design, Tailwind 4, React Router 7, TypeScript | `autorin-web/package.json` |
| Backend | NestJS 11, GraphQL (Apollo), Mongoose/MongoDB, Redis/BullMQ, class-validator, JWT/OTP auth | `autorin-backend/package.json` |
| Mobile | Flutter 3.x, graphql_flutter, flutter_bloc, provider, go_router | `my_auto/pubspec.yaml` |
| API style | Primary GraphQL at `/api`; some REST upload/media routes | `autorin-backend/src/main.ts` |
| DB | MongoDB via Mongoose | docker-compose + mongoose |
| i18n | uz / ru / en object strings | product rule |

## Test Stack

| Kind | Tool | Location | Notes |
|------|------|----------|-------|
| Web E2E | Playwright Test | `qa/web/` | Installed during QA setup |
| Backend unit | Jest + ts-jest + @nestjs/testing | `autorin-backend/src/**/*.spec.ts` | Existing |
| Backend e2e script | `test:e2e` referenced | `autorin-backend` jest-e2e config **missing** at install time | Treat as gap |
| API smoke | Node fetch scripts | `qa/backend/tests/` | Local only |
| Flutter unit/widget | flutter_test | `my_auto/test/` | Existing |
| Mobile E2E | Maestro YAML | `qa/mobile/maestro/` | CLI optional |
| Flutter integration | Scaffold only | `qa/mobile/integration_test/` | Not wired into app yet |
| Perf | k6 script | `qa/performance/k6-smoke.js` | k6 binary optional |
| Security | header smoke + npm audit; ZAP optional | `qa/backend/tests/security-headers.mjs` | |
| Visual | Playwright screenshots | `qa/screenshots/` | Baselines TBD |
| Contract | Fixture contract tests | `qa/backend/tests/api-contract.smoke.test.mjs` | Pact not installed |

**team_maturity:** startup → growing (Chromium-first local; expand browsers in CI)

## CI/CD

- GitHub workflows may exist under `.github/` — verify before assuming gates
- QA runner produces artifacts under `qa/reports/`
- Desired: PR smoke (web chromium + jest + flutter test); nightly extended

## Environments

| Env | Use | Rule |
|-----|-----|------|
| Local | Default for all automation | Mongo/Redis via backend containers |
| Staging | Optional when provided | Same `QA_*` vars |
| Production | Forbidden unless user explicitly allows | |

## Quality Goals

- Smoke suite green on local before release candidates
- Distinct PASS / FAIL / BLOCKED / PASS_WITH_NOTES
- No secret leakage in reports
- Prefer coverage of auth, RBAC, orders, products, moderation

## Risk Areas

| Area | Impact | Likelihood | Notes |
|------|--------|------------|-------|
| Auth / OTP / sessions | High | Medium | Existing unit specs present |
| Admin RBAC | High | Medium | Admin vs moderator layouts |
| GraphQL authz | High | Medium | |
| File/media upload | High | Medium | |
| Messaging | Medium | Medium | |
| Mobile offline | Medium | Medium | connectivity_plus present |
| i18n regressions | Low–Med | Medium | uz/ru/en |

## Team / Conventions

- Selector strategy: Playwright user-facing locators (`getByRole` / label); `data-testid` only when needed
- Tests live under `qa/` for new automation; keep Nest `*.spec.ts` co-located
- Bug reports: `qa/bug-reports/`
- Test plans: `qa/test-plans/`
- Orchestrator: `.cursor/skills/full-stack-qa`
- Safety: `.cursor/rules/qa-safety.mdc`

## Commands

```bash
npm --prefix qa run qa:full
npm --prefix qa run qa:web
npm --prefix qa run qa:backend
npm --prefix qa run qa:flutter
npm --prefix qa run qa:security
npm --prefix qa run qa:performance
npm --prefix qa run qa:regression
npm --prefix qa run qa:report
```
