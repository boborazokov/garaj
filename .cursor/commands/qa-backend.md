---
description: Run AutoRin backend / GraphQL QA
---

Use **full-stack-qa** + **api-testing** + **unit-testing**. Follow qa-safety.

1. Prefer local API on :7007 for GraphQL smoke.
2. Run: `npm --prefix qa run qa:backend`
3. Mark GraphQL smoke BLOCKED if server is down; still report Jest results honestly.
