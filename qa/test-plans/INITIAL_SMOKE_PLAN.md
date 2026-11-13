# Initial smoke plan (installation baseline)

Environment: **local only**

| ID | Surface | Case | Priority | Automation |
|----|---------|------|----------|------------|
| W1 | Web | Sign-in page renders | P0 | Playwright `@smoke` |
| W2 | Web | Empty submit stays on sign-in | P0 | Playwright |
| W3 | Web | Unauth `/admin` guard | P0 | Playwright |
| W4 | Web | `/signup` → `/sign-in` | P0 | Playwright |
| W5 | Web | Responsive screenshots | P1 | Playwright |
| W6 | Web | GraphQL offline on sign-in | P1 | Playwright route abort |
| B1 | Backend | Existing Jest unit specs | P0 | `npm test` |
| B2 | Backend | GraphQL reachable | P0 | `graphql-smoke.mjs` |
| B3 | Backend | Fixture contract | P0 | node:test |
| F1 | Flutter | `flutter test` | P0 | flutter_test |
| F2 | Flutter | `flutter analyze` | P1 | analyzer |
| S1 | Security | Header observation | P2 | Node script |
| P1 | Perf | k6 smoke | P2 | BLOCKED until k6 installed |

Execution: `npm --prefix qa run qa:full`
