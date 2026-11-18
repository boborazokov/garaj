# Dependency migration notes (deferred majors)

Date: 2026-11-13  
Branch: `fix/qa-security-hardening-2026-11-13`

## `@apollo/server` (GHSA-9q82-xgwf-vj6h)

| Item | Detail |
| --- | --- |
| Installed | `4.13.0` |
| Affected | `<5.5.0` |
| Patched | `5.5.x` |
| Blocker | `@nestjs/apollo@13.1.0` peers `@apollo/server@^4.11.3` |
| Safe in this task? | **No** — requires Nest Apollo / GraphQL driver upgrade to a release that peers Apollo 5 |
| Mitigation now | `csrfPrevention: true`, production introspection forced off, stacktraces off |
| Recommended | Separate migration: bump `@nestjs/apollo` + `@nestjs/graphql` to Apollo-5-compatible versions, then `@apollo/server@^5.5.2`, full GraphQL regression |

## `sharp` (libvips / libheif / librsvg advisories)

| Item | Detail |
| --- | --- |
| Installed | `0.34.5` |
| Patched | `0.35.5` (major line; Node `>=20.9.0`) |
| Safe in this task? | **Deferred** — native binary rebuild risk on Windows/CI/Render |
| Mitigation now | Upload size limits already configured; restrict content types in upload pipeline as follow-up |
| Recommended | Dedicated spike: upgrade `sharp@0.35.5`, rebuild native deps, re-test image/video compression + Render deploy |

## `@graphql-tools/utils`

| Item | Detail |
| --- | --- |
| Was | `12.0.0` (vulnerable) |
| Now | **`12.0.4` via npm/pnpm overrides** |
| Advisories | GHSA-7mx3 (`<=12.0.0`), GHSA-c4qx (`<=12.0.1`) — installed version outside both |

## React Router (GHSA-qwww-vcr4-c8h2)

| Item | Detail |
| --- | --- |
| Installed | `react-router` / `react-router-dom` **7.18.5** |
| Affected | `>=7.12.0 <7.18.2` (RSC mode only) |
| Actually vulnerable? | **No** — 7.18.5 ≥ 7.18.2 patched line |
| Prior report error | Final verification incorrectly marked 7.18.5 in-range; corrected |
