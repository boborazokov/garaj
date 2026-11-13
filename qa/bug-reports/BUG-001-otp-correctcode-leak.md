# BUG-001 — OTP `correctCode` returned by GraphQL `signUp`

- **Severity:** High (Critical if `NODE_ENV` mis-set on any shared/staging host)
- **Module:** Backend / Auth (`autorin-backend`)
- **Status:** Reproduced locally; not fixed

## Reproduction
1. Ensure backend runs with non-production `NODE_ENV`.
2. `POST http://127.0.0.1:7007/api` with:
   ```graphql
   mutation { signUp(data: { phone: "+998901119998", password: "QaAuditPass123!", name: "QA" }) { token correctCode } }
   ```
3. Observe response `data.signUp.correctCode` is a numeric OTP.

## Expected
OTP never leaves the server (SMS/out-of-band only). GraphQL must not expose plaintext OTP.

## Actual
`correctCode` returned in GraphQL payload (value redacted in reports). Code path: `auth.service.ts` assigns `output.correctCode` when `!isProductionEnv(NODE_ENV)`. Web client also queries `correctCode` in `operations.ts`.

## Evidence
- `qa/reports/backend-graphql-probes.json` → `signUp-otp-leak-check` **FAIL**
- Source: `autorin-backend/src/modules/auth/service/auth.service.ts` (~L110–112, ~L255–257)

## Suggested fix (needs approval)
1. Remove `correctCode` from GraphQL schema / `ConfirmationOutput` for all environments, **or** gate behind an explicit `QA_EXPOSE_OTP=1` never enabled outside local.
2. Stop selecting `correctCode` from `autorin-web` and mobile clients.
3. Add regression test: signUp response must not contain OTP digits.
4. Verify staging/production `NODE_ENV=production`.
