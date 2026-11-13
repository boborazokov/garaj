---
description: Run full-stack AutoRin QA smoke (web + backend + Flutter)
---

Use the **full-stack-qa** skill and `.cursor/rules/qa-safety.mdc`.

1. Read `.agents/qa-project-context.md`.
2. Run: `npm --prefix qa run qa:full`
3. Summarize `qa/reports/LATEST.md` with PASS / FAIL / BLOCKED only from real output.
4. Do not modify application business logic or claim passes without execution.
