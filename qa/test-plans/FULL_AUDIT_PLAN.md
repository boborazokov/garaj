# Full Project QA Audit Plan — 2026-11-13

Environment: **local only** (`127.0.0.1:7007`, `:5173`)  
Safety: no production, no app source edits, no auto-fixes

## Modules

1. Backend — Jest unit + live GraphQL probes (auth, authz, validation, introspection)
2. Web — Playwright chromium (smoke + auth guard + network + responsive)
3. Flutter — `flutter test`, widget_test investigation, `flutter analyze`
4. Security — headers, npm audit, GraphQL abuse probes
5. Integration — web→API proxy, mobile env API host consistency

## Priority matrix

| ID | Area | Priority |
|----|------|----------|
| A1 | Auth invalid credentials | P0 |
| A2 | Authz without token | P0 |
| A3 | Authz with forged/expired token | P0 |
| A4 | Role gates (admin vs user) | P0 |
| B1 | Nest unit specs | P0 |
| W1 | Sign-in / redirects | P0 |
| W2 | Unauth admin routes | P0 |
| F1 | Existing flutter tests | P0 |
| F2 | widget_test.dart failure | P0 |
| S1 | Security headers / audit | P1 |
| I1 | Cross-client API contract | P1 |
