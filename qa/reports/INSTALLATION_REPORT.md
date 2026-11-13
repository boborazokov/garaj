# AutoRin QA Environment — Installation Report

**Date:** 2026-11-13  
**Installer role:** Senior QA Automation / Cursor configuration  
**Scope:** Install + verify only (no full product audit)

---

## 1. Project discovery (verified)

| Area | Finding | Evidence |
|------|---------|----------|
| Web frontend | React 19 + Vite 8 + Apollo + Ant Design + Tailwind + React Router | `autorin-web/package.json` |
| Backend | NestJS 11 + GraphQL (Apollo) + Mongoose/MongoDB + Redis/BullMQ | `autorin-backend/package.json` |
| APIs | GraphQL primary at `/api` (port **7007**); REST for upload/media | `autorin-backend/src/main.ts`, Vite proxy |
| Database / ORM | MongoDB + Mongoose | package + docker-compose |
| Mobile | Flutter (`my_auto`), go_router, flutter_bloc, provider, graphql_flutter | `my_auto/pubspec.yaml` |
| Architecture | Monorepo: `autorin-web`, `autorin-backend`, `my_auto` | repo root |
| Existing tests | Nest `*.spec.ts` (Jest); Flutter `my_auto/test/*`; no Playwright before | discovery |
| Cursor rules/skills (pre-existing) | `autorin-product`, `graphify`, `ui-minimal`, `web-file-structure`; skills `graphify`, `mobile-app-uiux-pro-max`, `unslop` | `.cursor/` |

Application **business logic was not modified**.

---

## 2. Installed skills

**Source:** https://github.com/petrkindlmann/qa-skills  
**Command:**

```bash
npx skills add petrkindlmann/qa-skills -a cursor -s "*" -y --copy
```

**Location:** `.agents/skills/<skill-name>/` (Agent Skills Standard; Cursor tracked)  
**Lockfile:** `skills-lock.json`  
**Count:** 50 QA skills from the package (+ pre-existing non-QA skills under `.agents` / `.cursor`)

### Skills matching requested domains (actual names)

| Requested domain | Installed skill name |
|------------------|----------------------|
| QA project context | `qa-project-context` |
| QA workflow | `qa-start`, `qa-do` |
| Test strategy | `test-strategy` |
| Test planning | `test-planning` |
| Risk-based testing | `risk-based-testing` |
| Exploratory testing | `exploratory-testing` |
| Playwright automation | `playwright-automation` |
| API testing | `api-testing` |
| Unit testing | `unit-testing` |
| Integration testing | (covered via `api-testing` + Nest Jest e2e scripts + `service-virtualization`) |
| Mobile testing | `mobile-testing` |
| Visual testing | `visual-testing` |
| Performance testing | `performance-testing` |
| Security testing | `security-testing` |
| Accessibility testing | `accessibility-testing` |
| Database testing | `database-testing` |
| Contract testing | `contract-testing` |

**Also installed (full package):**  
`agentic-browser-testing`, `ai-bug-triage`, `ai-qa-review`, `ai-system-testing`, `ai-test-generation`, `analytics-tracking-testing`, `bug-reproduction`, `chaos-engineering`, `ci-cd-integration`, `compliance-testing`, `coverage-analysis`, `cross-browser-testing`, `cypress-automation`, `email-testing`, `observability-driven-testing`, `payment-testing`, `qa-dashboard`, `qa-metrics`, `qa-project-bootstrap`, `qa-report-humanizer`, `quality-postmortem`, `release-readiness`, `selector-drift-recovery`, `service-virtualization`, `shift-left-testing`, `synthetic-monitoring`, `test-case-management`, `test-data-management`, `test-environments`, `test-migration`, `test-reliability`, `test-suite-curation`, `testing-in-production`

**Verification:** `ALL_REQUIRED_SKILLS_OK` for the 18 core domain skills listed above (`SKILL.md` present for each).

**Orchestrator (project-authored):** `.cursor/skills/full-stack-qa/SKILL.md`

---

## 3. Installed / configured tools

| Tool | Status | Notes |
|------|--------|-------|
| Playwright Test **1.65.0** | Installed | `qa/web/` + Chromium browser |
| Playwright Firefox/WebKit | Configured in `playwright.config.ts` | Run `npm run install:browsers --prefix qa/web` for full matrix |
| Nest Jest + Supertest | Already present | Reused via `qa:backend` |
| flutter_test | Already present | Reused via `qa:flutter` |
| flutter analyze | Available | Ran; reports existing infos/warnings in app |
| Newman / Postman CLI | **Not reliably runnable** | `npx newman` fails on Node 24 (`colors/safe`); optional — prefer Playwright API / Nest tests |
| k6 | **Not installed** | Script ready: `qa/performance/k6-smoke.js` |
| OWASP ZAP | **Not installed** | Header smoke only; full DAST manual |
| Maestro CLI | **Not installed** | YAML flows ready: `qa/mobile/maestro/` (`appId: garaj.uz`) |
| Patrol | **Not installed** | Compatible with Flutter; deferred (needs native project hooks) — documented in `qa/mobile/README.md` |
| Node.js | v24.21.0 | |
| npm | 11.19.0 | |
| Flutter | 3.47.1 stable | Device: Android phone + Windows/Chrome available |

---

## 4. Modified / created configuration files

### Created

- `.cursor/rules/qa-safety.mdc`
- `.cursor/skills/full-stack-qa/SKILL.md`
- `.cursor/commands/qa-full.md`, `qa-web.md`, `qa-backend.md`, `qa-flutter.md`, `qa-security.md`, `qa-performance.md`, `qa-regression.md`, `qa-report.md`
- `.agents/qa-project-context.md`
- `.agents/skills/*` (50 skills from qa-skills)
- `skills-lock.json`
- `qa/` tree (see structure below)
- `qa/web/playwright.config.ts`, tests, page objects, `.env.example`
- `qa/backend/` GraphQL/API smoke scripts
- `qa/mobile/` Maestro + integration scaffold + plan
- `qa/performance/k6-smoke.js`
- `qa/scripts/run-qa.mjs`, `qa/package.json`, `qa/README.md`

### Not modified

- Application source under `autorin-web/src`, `autorin-backend/src`, `my_auto/lib` (business logic untouched)
- Existing Nest/Vite/Flutter app configs left as-is

### Directory layout

```
qa/
  reports/          # run evidence + this INSTALLATION_REPORT
  test-plans/
  bug-reports/
  test-data/
  screenshots/
  fixtures/
  web/              # Playwright
  backend/          # API/GraphQL helpers
  mobile/           # Maestro + Flutter plan
  performance/      # k6
  api/newman/       # Newman notes
  scripts/run-qa.mjs
```

---

## 5. Installation commands (executed)

```bash
npx skills add petrkindlmann/qa-skills -a cursor -s "*" -y --copy
cd qa/web && npm install && npx playwright install chromium
cd qa/backend && npm install
# packages under qa/ created via Write tooling
```

---

## 6. Verification results (executed)

| Check | Result | Detail |
|-------|--------|--------|
| Required QA skills present | **PASS** | 18/18 core domain skills |
| Playwright version | **PASS** | 1.65.0 |
| Playwright `@smoke` (no server) | **BLOCKED** | Web not on :5173 |
| Playwright `@smoke` (`QA_START_WEB=1`) | **PASS** | ~23s |
| Backend Jest unit | **PASS** | exit 0 |
| Backend GraphQL smoke | **PASS** (after API up) | `__typename=Query` @ `:7007/api` |
| Backend fixture contract | **PASS** | node:test |
| Security workflow | **PASS_WITH_NOTES** | Headers observed; ZAP missing |
| Performance workflow | **BLOCKED** | k6 missing |
| Flutter `flutter test` | **FAIL** (pre-existing) | `8 passed, 1 failed` — stale `widget_test.dart` counter template |
| Flutter analyze | **PASS_WITH_NOTES** | 154 existing info/warning issues; not introduced by QA install |
| Newman | **BLOCKED** | Broken under current Node/npx |
| Maestro / Patrol / ZAP / k6 | **BLOCKED** | Not on PATH |

Reports written under `qa/reports/qa-run-*.md` and `LATEST.md`.

---

## 7. Missing dependencies / gaps

1. **k6** — install for `qa:performance`
2. **Maestro CLI** — install for mobile YAML flows
3. **OWASP ZAP** — optional DAST
4. **Firefox + WebKit** Playwright browsers — `npm run install:browsers --prefix qa/web`
5. **Newman** — optional; currently broken via `npx` on Node 24
6. **Patrol** — optional Flutter-native E2E (requires pub + Android/iOS setup)
7. **`integration_test`** — scaffold only; not added to `my_auto/pubspec.yaml` (opt-in)
8. **Nest `test/jest-e2e.json`** — referenced by `test:e2e` script but directory/config missing at install time
9. **Stale Flutter template test** — `my_auto/test/widget_test.dart` still expects a counter app (pre-existing FAIL)

---

## 8. Remaining manual setup

1. Copy `qa/web/.env.example` → `qa/web/.env` and `qa/backend/.env.example` → `qa/backend/.env` (test accounts only).
2. Keep backend on `:7007` and/or web on `:5173` for live smokes, or use `QA_START_WEB=1`.
3. Install optional CLIs (k6, Maestro, ZAP) if those workflows are needed.
4. Decide whether to adopt Patrol / `integration_test` inside `my_auto` (requires app project changes — ask before applying).
5. Replace/remove obsolete `widget_test.dart` counter test when authorized to touch app tests.
6. Add CI job calling `npm --prefix qa run qa:regression` when ready.

---

## 9. How to run each QA workflow

From **repo root**:

```bash
npm --prefix qa run qa:full          # 1. Full project QA
npm --prefix qa run qa:web           # 2. Web QA
npm --prefix qa run qa:backend       # 3. Backend QA
npm --prefix qa run qa:flutter       # 4. Flutter QA
npm --prefix qa run qa:security      # 5. Security audit
npm --prefix qa run qa:performance   # 6. Performance audit
npm --prefix qa run qa:regression    # 7. Regression
npm --prefix qa run qa:report        # 8. Generate/show QA report
```

Cursor slash commands mirror these under `.cursor/commands/qa-*.md`.  
Agent orchestration: skill **full-stack-qa** + library skills in `.agents/skills/`.

**Web tip:**

```powershell
$env:QA_START_WEB='1'; npm --prefix qa run qa:web
```

---

## 10. Safety confirmation

- No production targeting in defaults (`127.0.0.1` only)
- No production data deletion
- No secrets committed (`.env` gitignored; examples only)
- No automatic bug fixes applied to application code
- Results marked PASS / FAIL / BLOCKED / PASS_WITH_NOTES from real runs only

---

*End of installation report. Full product audit intentionally not started.*
