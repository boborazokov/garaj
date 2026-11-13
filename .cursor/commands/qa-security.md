---
description: Run AutoRin security audit smoke
---

Use **full-stack-qa** + **security-testing**. Follow qa-safety — never scan production without permission.

1. Run: `npm --prefix qa run qa:security`
2. Note ZAP/OSV as BLOCKED if tools missing.
3. File findings under `qa/bug-reports/`; do not auto-fix.
