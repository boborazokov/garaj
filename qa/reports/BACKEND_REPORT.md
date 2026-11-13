# Backend QA Report — post-fix

**Branch:** `fix/qa-security-hardening-2026-11-13`

## Results

| Suite | Result | Evidence |
|-------|--------|----------|
| Jest | **PASS** 38 tests / 11 suites | `postfix-backend-jest.txt` |
| `nest build` | **PASS** | `postfix-backend-build.txt` |
| GraphQL probes | **PASS** 8 / 1 PASS_WITH_NOTES | `postfix-graphql-probes.txt` |
| Security headers | X-Powered-By **null**, XFO=DENY, XCTO=nosniff | `postfix-security-headers.txt` |

## Fixes landed
BUG-001, BUG-002, BUG-003 (helmet), BUG-004 (introspection flag), BUG-009 (partial), pnpm `ws` override.

## Residual
Backend `npm audit --omit=dev` still reports transitive advisories; `pnpm audit --prod` ~17 (no critical in last pnpm prod summary). Breaking `@nestjs/graphql` major avoided.
