# BUG-002 — GraphQL errors expose stacktraces

- **Severity:** High
- **Module:** Backend / GraphQL error handling
- **Final status:** **FIXED**

## Root cause
`formatGraphqlError` spread Apollo `formattedError.extensions`, retaining `stacktrace`. Validation GraphQLErrors mapped to `INTERNAL_ERROR`.

## Fix implemented
- Rebuild client extensions from scratch (no stacktrace inheritance)
- Map GraphQL validation/parse/bad-input to `VALIDATION_FAILED`
- `includeStacktraceInErrorResponses: false` in Apollo config
- Scrub path-like debug strings; omit debug in production

## Files changed
- `autorin-backend/src/common/errors/format-graphql-error.ts`
- `autorin-backend/src/common/errors/format-graphql-error.spec.ts` (new)
- `autorin-backend/src/configs/graphql/graphql.config.ts`

## Tests
- Unit: `format-graphql-error.spec.ts` **PASS**
- Live probes: invalid creds / unauth / validation — **no stacktrace**; validation **PASS**
