---
name: full-stack-qa
description: >-
  Coordinate AutoRin full-stack QA across web (Playwright), backend (NestJS/Jest/
  GraphQL), and Flutter (flutter_test/Maestro/Patrol). Creates test plans, runs
  safe smoke/regression workflows, analyzes failures, captures screenshots/logs,
  writes reports under qa/reports, and identifies coverage gaps. Use when the
  user asks for full project QA, web QA, backend QA, Flutter QA, security audit,
  performance audit, regression testing, or generate QA report.
license: MIT
metadata:
  author: autorin
  version: "1.0"
  category: orchestration
---

# Full-Stack QA (AutoRin)

Orchestrates installed QA skills for this monorepo. **Do not modify application business logic.** Follow `.cursor/rules/qa-safety.mdc`.

## Before anything

1. Read `.agents/qa-project-context.md`.
2. Run `graphify query "<topic>"` before broad codebase exploration (workspace rule).
3. Confirm target environment is local/staging — never production without explicit permission.

## Installed skill routing

| Need | Skill(s) |
|------|----------|
| Bootstrap / context | `qa-project-context`, `qa-start`, `qa-do` |
| Strategy / plan | `test-strategy`, `test-planning`, `risk-based-testing`, `exploratory-testing` |
| Web E2E | `playwright-automation`, `visual-testing`, `cross-browser-testing`, `accessibility-testing` |
| API / GraphQL | `api-testing`, `contract-testing`, `service-virtualization` |
| Unit / integration | `unit-testing`, `coverage-analysis` |
| Mobile / Flutter | `mobile-testing` |
| DB | `database-testing` |
| Perf | `performance-testing` |
| Security | `security-testing` |
| Failures / bugs | `bug-reproduction`, `ai-bug-triage`, `test-reliability`, `qa-report-humanizer` |
| Release | `release-readiness`, `test-suite-curation` |

Skills live under `.agents/skills/<name>/SKILL.md`.

## Workflows (executable)

From repo root (or `qa/`):

```bash
npm --prefix qa run qa:full          # web + backend + flutter smoke
npm --prefix qa run qa:web           # Playwright @smoke
npm --prefix qa run qa:backend       # Jest + GraphQL smoke + fixtures
npm --prefix qa run qa:flutter       # flutter test + analyze
npm --prefix qa run qa:security      # headers + npm audit (+ ZAP if present)
npm --prefix qa run qa:performance   # k6 if installed
npm --prefix qa run qa:regression    # web + unit + flutter
npm --prefix qa run qa:report        # print qa/reports/LATEST.md
```

Agent natural-language aliases:

1. **Full project QA** → `qa:full` + `test-strategy` summary
2. **Web QA** → `playwright-automation` + `qa:web`
3. **Backend QA** → `api-testing` + `unit-testing` + `qa:backend`
4. **Flutter QA** → `mobile-testing` + `qa:flutter`
5. **Security audit** → `security-testing` + `qa:security` (ZAP optional)
6. **Performance audit** → `performance-testing` + `qa:performance`
7. **Regression** → `qa:regression`
8. **Generate QA report** → `qa:report` + write `qa/reports/...` via `qa-report-humanizer`

## Agent procedure

1. **Inspect** — stack from qa-project-context; graphify for hotspots.
2. **Plan** — use `test-planning` / `risk-based-testing`; store under `qa/test-plans/`.
3. **Execute** — run the matching `npm --prefix qa run qa:*` command. Capture stdout/stderr.
4. **Analyze failures** — `bug-reproduction` / `test-reliability`; do **not** auto-fix app code.
5. **Evidence** — screenshots → `qa/screenshots/`; artifacts from Playwright outputDir; logs in report JSON.
6. **Report** — `qa/reports/` with PASS / FAIL / BLOCKED / PASS_WITH_NOTES only from real runs.
7. **Coverage gaps** — `coverage-analysis` + list untested critical journeys (auth, orders, products, moderation, messaging).

## Paths

```
qa/
  web/                 Playwright
  backend/             GraphQL/API helpers
  mobile/              Maestro + Flutter plan
  performance/         k6 scripts
  reports/             run evidence
  test-plans/
  bug-reports/
  test-data/
  screenshots/
  fixtures/
```

## Anti-patterns

- Inventing green results
- Running against production URLs in `.env`
- Committing real phones/passwords
- Editing Nest/React/Flutter business modules “to make tests pass”
- Skipping BLOCKED when tools/servers are down
