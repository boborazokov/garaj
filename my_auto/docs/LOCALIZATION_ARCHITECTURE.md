# Localization architecture (AutoRin)

Enterprise-grade i18n: **backend returns codes only**, **Flutter renders all user-facing text**.

## 1. Recommended architecture

```
┌─────────────────┐     GraphQL/REST      ┌──────────────────────────────┐
│  Flutter app    │ ◄── extensions.code ──│  NestJS API                  │
│  ARB → S.of()   │     (no user copy)    │  ApiErrorCode + debug (en) │
│  ApiErrorMapper │                       │  formatGraphqlError()        │
└─────────────────┘                       └──────────────────────────────┘
```

| Layer | Responsibility |
|--------|----------------|
| **Backend** | Business rules, stable `ApiErrorCode`, English `debug` for logs/dev |
| **Flutter** | All UI strings (en/ru/uz), map `code` → localized snackbar/dialog |
| **Never** | Translate errors in SQL, services, or GraphQL `message` for end users |

## 2. Backend

### Response shape

**GraphQL error (client-facing):**

```json
{
  "message": "AUTH_INVALID_OTP",
  "extensions": {
    "success": false,
    "code": "AUTH_INVALID_OTP",
    "debug": "OTP bcrypt mismatch"
  }
}
```

In **production**, `debug` is omitted from `extensions` (see `formatGraphqlError`).

**REST error:**

```json
{
  "success": false,
  "code": "DEVICE_OFFLINE",
  "debug": "No active websocket session",
  "statusCode": 400,
  "timestamp": "...",
  "path": "/api/..."
}
```

### Throwing errors (preferred)

```typescript
import { ApiErrorCode, throwApi } from 'src/common/errors';

throwApi(ApiErrorCode.AUTH_INVALID_OTP, {
  debug: 'OTP bcrypt mismatch',
});
```

### File layout

```
autorin-backend/src/common/errors/
  api-error-code.enum.ts    # Single source of truth for codes
  api-error.response.ts     # { success, code, debug? }
  api.exception.ts          # HttpException wrapper + throwApi()
  legacy-message-map.ts     # Migration map from old English strings
  format-graphql-error.ts   # Apollo formatError
  index.ts
```

### Error code groups

| Prefix | Examples |
|--------|----------|
| `AUTH_*` | `AUTH_UNAUTHORIZED`, `AUTH_INVALID_OTP` |
| `VALIDATION_*` | `VALIDATION_FILE_TOO_LARGE` |
| `ORDER_*`, `PART_*`, … | Resource-specific not-found |
| `BUSINESS_*` | Domain rules (cannot review own, rate limit) |
| `WS_*`, `DEVICE_*` | Realtime / push |
| `INTERNAL_ERROR` | Unhandled 5xx |

## 3. Flutter

### Folder structure

```
lib/
  l10n/
    intl_en.arb          # Template (edit + intl_utils:generate)
    intl_ru.arb
    intl_uz.arb
  generated/
    l10n.dart            # S.of(context) — runtime (intl_utils)
  core/
    errors/
      api_error_code.dart
      api_error_payload.dart
      api_error_mapper.dart
    l10n/
      locale_resolution.dart
```

**Workflow:** edit `lib/l10n/intl_*.arb` → `dart run intl_utils:generate` → commit `lib/generated/`.

Do **not** hand-edit `lib/generated/l10n.dart`.

### ARB example

```json
"errorAuthInvalidOtp": "Invalid verification code.",
"@errorAuthInvalidOtp": {
  "description": "Backend code AUTH_INVALID_OTP"
}
```

### When to show errors to users

| Situation | Show toast? |
|-----------|-------------|
| User tapped Login / Save / Submit | Yes — `UserFacingErrors.show(..., presentation: userAction)` |
| Home feed, map, discovery, push token | No — inline empty state / retry only |
| Global GraphQL `ErrorLink` | No — logs in debug; only **session expired** toast |

```dart
import 'package:my_auto/core/errors/user_facing_errors.dart';

// After user taps a button
UserFacingErrors.show(
  context,
  presentation: ErrorPresentation.userAction,
  result: queryResult,
);

// Background load — never toast
// store error in state, show inline widget
```

### Usage in UI (low-level)

```dart
import 'package:my_auto/core/errors/api_error_mapper.dart';
import 'package:my_auto/generated/l10n.dart';

// Snackbar from GraphQL
Toaster.error(ApiErrorMapper.messageFromGraphqlError(context, gqlError));

// From bloc failure carrying wire code
final code = ApiErrorCode.tryParse(state.failure?.message);
if (code != null) {
  text = ApiErrorMapper.localize(
    context,
    ApiErrorPayload(code: code),
  );
}
```

### Dynamic language

- `LocaleNotifier` persists `languageCode` (`en` | `ru` | `uz`).
- `MaterialApp.locale` + `localeResolutionCallback` → `resolveAppLocale()` with **English fallback**.

### Branding: Avto Xizmatlar

Uzbek UI uses **Avto Xizmatlar** instead of *ustaxona*. EN: *Auto Services*, RU: *Авто услуги*.

## 4. Error code mapping

| Backend `ApiErrorCode` | Flutter ARB key |
|------------------------|-----------------|
| `AUTH_INVALID_OTP` | `errorAuthInvalidOtp` |
| `AUTH_USER_EXISTS` | `errorAuthUserExists` |
| `ORDER_NOT_FOUND` | `errorOrderNotFound` |
| `DEVICE_OFFLINE` | `errorDeviceOffline` |

Keep `lib/core/errors/api_error_code.dart` in sync with backend enum.

## 5. Migration strategy

### Phase 1 — Foundation ✅
- [x] `common/errors` module + `formatError`
- [x] Auth module on `throwApi`
- [x] Flutter `ApiErrorMapper` + GraphQL `ErrorLink`
- [x] Error ARB keys (en/ru/uz)

### Phase 2 — Backend sweep
1. Replace each `BadRequestException('…')` with `throwApi(ApiErrorCode.…, { debug })`.
2. Add code to `legacy-message-map.ts` until throw site is migrated.
3. Remove legacy map entries when grep shows zero English throws.

### Phase 3 — Flutter sweep
1. Remove hardcoded `Text('…')` in features (grep `Text\('` without `S.of`).
2. Route all `Toaster.error` / `SnackBar` through `ApiErrorMapper`.
3. Bloc failures: store `ApiErrorCode.wireValue`, not English `message`.

### Phase 4 — QA
- Switch language in profile → verify errors/toasts/empty states.
- Regression: auth, orders, chat, uploads, WS reconnect.

## 6. Production recommendations

- **CI:** `dart run intl_utils:generate` + fail if `git diff` on `lib/generated/`.
- **CI:** Grep gate: no new `BadRequestException('` without review.
- **Logging:** Log `debug` + `code` server-side; never log passwords/tokens.
- **Analytics:** Track `code` counts, not raw messages.
- **Products:** Defer part-level reviews; use seller/workshop/service ratings first.

## 7. Best practices

1. One code per distinct user action outcome.
2. `debug` is for engineers only (English).
3. Never branch UI on English `message` after migration.
4. Parameterized strings: `"greeting": "Hello, {name}"` with `@greeting` placeholders in ARB.
5. Uzbek: Latin script only in ARB (`uz`, not `uz_Cyrl`).
