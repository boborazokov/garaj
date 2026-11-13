# BUG-001 — OTP `correctCode` returned by GraphQL `signUp`

- **Severity:** High (Critical if `NODE_ENV` mis-set on any shared/staging host)
- **Module:** Backend / Auth (`autorin-backend`) + Web + Flutter clients
- **Final status:** **FIXED**

## Original finding
Non-prod GraphQL `signUp` / `requestPasswordReset` returned `correctCode`. Clients selected it.

## Root cause
`ConfirmationOutput` exposed `@Field() correctCode`; `auth.service.ts` assigned OTP when `!isProductionEnv`.

## Fix implemented
- Removed field from GraphQL type + `schema.gql`
- Stopped assigning OTP to API responses (SMS / server log only)
- Removed selections from web `operations.ts`, Flutter `auth_api.dart`, reset/sign-up flows, router extras

## Files changed
- `autorin-backend/src/modules/auth/types/confirmation.type.ts`
- `autorin-backend/src/modules/auth/service/auth.service.ts`
- `autorin-backend/schema.gql`
- `autorin-web/src/graphql/operations.ts`
- `my_auto/lib/features/auth/data/api/auth_api.dart`
- `my_auto/lib/features/auth/presentation/providers/sign_up_provider.dart`
- `my_auto/lib/features/auth/presentation/screens/confirmation_screen.dart`
- `my_auto/lib/features/auth/presentation/screens/reset_password_screen.dart`
- `my_auto/lib/core/routes/app_router.dart`

## Tests
- `node qa/backend/tests/audit-graphql-probes.mjs` → `signUp-otp-leak-check` **PASS**
- Backend Jest **PASS** (38)

## Remaining risks
Local SMS `log` provider still prints OTP to **server logs** in development (not GraphQL). Acceptable for local only.
