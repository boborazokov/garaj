# AutoRin QA

Isolated QA harness for `autorin-web`, `autorin-backend`, and `my_auto`.

## Quick start

```bash
# from repo root
npm --prefix qa run qa:web:install   # once
npm --prefix qa run qa:full
```

Copy env examples:

```bash
copy qa\web\.env.example qa\web\.env
copy qa\backend\.env.example qa\backend\.env
```

## Workflows

| Command | Purpose |
|---------|---------|
| `npm --prefix qa run qa:full` | Web + backend + Flutter |
| `npm --prefix qa run qa:web` | Playwright `@smoke` |
| `npm --prefix qa run qa:backend` | Jest + GraphQL smoke + fixtures |
| `npm --prefix qa run qa:flutter` | `flutter test` + `analyze` |
| `npm --prefix qa run qa:security` | Headers + npm audit (+ ZAP if present) |
| `npm --prefix qa run qa:performance` | k6 (if installed) |
| `npm --prefix qa run qa:regression` | Web + unit + Flutter |
| `npm --prefix qa run qa:report` | Print `qa/reports/LATEST.md` |

Set `QA_START_WEB=1` to auto-start Vite for Playwright.

## Cursor

- Rule: `.cursor/rules/qa-safety.mdc`
- Orchestrator skill: `.cursor/skills/full-stack-qa`
- Slash commands: `.cursor/commands/qa-*.md`
- Library skills: `.agents/skills/*` (petrkindlmann/qa-skills)
- Context: `.agents/qa-project-context.md`

## Safety

Local/staging only. Never production without explicit permission. No auto bug-fixes.
