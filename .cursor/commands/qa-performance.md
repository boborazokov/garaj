---
description: Run AutoRin performance audit
---

Use **full-stack-qa** + **performance-testing**. Local/staging only.

1. Run: `npm --prefix qa run qa:performance`
2. If k6 missing, status is BLOCKED; script lives at `qa/performance/k6-smoke.js`.
