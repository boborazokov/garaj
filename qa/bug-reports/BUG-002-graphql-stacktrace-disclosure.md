# BUG-002 — GraphQL errors expose stacktraces

- **Severity:** High
- **Module:** Backend / GraphQL error handling
- **Status:** Reproduced; not fixed

## Reproduction
1. `POST /api` with invalid credentials `signIn` or unauthenticated `getAdminStats`.
2. Inspect `errors[].extensions.stacktrace` and `debug`.

## Expected
Clients receive stable error codes (`AUTH_INVALID_CREDENTIALS`, `AUTH_UNAUTHORIZED`) without filesystem paths or stack frames.

## Actual
Responses include `extensions.stacktrace` arrays (Node paths under `autorin-backend`) for auth failures and validation errors. Validation failures are also labeled `INTERNAL_ERROR`.

## Evidence
- Live probes: `signIn-invalid-credentials`, `getAdminStats-unauth`, `validation-error-no-stacktrace` (**FAIL**)
- `qa/reports/backend-graphql-probes.json`, `qa/reports/backend-public-catalog.json`

## Suggested fix (needs approval)
1. Disable Apollo `includeStacktraceInErrorResponses` outside local debug.
2. Map GraphQL validation errors to a non-internal code; strip `stacktrace`/`debug` in production filter.
3. Add API test asserting absence of `stacktrace` keys.
