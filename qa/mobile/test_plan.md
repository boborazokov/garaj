# Flutter QA checklist (my_auto)

Status: **prepared** — run with `flutter test` / Maestro when device + env ready.

| Area | Priority | Approach | Status |
|------|----------|----------|--------|
| Login / OTP | P0 | Widget + Maestro / Patrol | Pending |
| Navigation (go_router) | P0 | Widget + integration | Pending |
| Forms / validation | P0 | Widget tests | Pending |
| API (GraphQL) | P0 | Mocked client + golden paths | Pending |
| Loading / error / empty | P0 | Widget states | Partial (need coverage) |
| Offline / connectivity | P1 | connectivity_plus mocks | Pending |
| Permissions | P1 | Patrol preferred | Pending |
| Deep links | P1 | go_router + Maestro | Pending |
| App lifecycle | P1 | integration_test | Pending |
| Screen sizes | P1 | golden / Patrol | Pending |
| Android device | P0 | `flutter test` + device | Device available |
| iOS | P1 | macOS required | BLOCKED on Windows host |

Safety: never point mobile builds at production GraphQL without permission.
