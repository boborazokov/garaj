# Backend localization architecture

The API is **localization-ready**, not localized. Clients translate `code`; the server never returns user-facing copy in Russian/Uzbek/English for errors.

## Standard error body

```typescript
interface ApiErrorResponse {
  success: false;
  code: ApiErrorCode;  // stable enum string
  debug?: string;      // English, dev/logs only
}
```

## GraphQL

Configured in `src/configs/graphql/graphql.config.ts`:

```typescript
formatError: (formattedError, error) =>
  formatGraphqlError(formattedError, error, { isProd }),
```

Client reads `errors[0].extensions.code`.

## REST

`HttpExceptionFilter` returns the same shape for `ApiException` throws.

## Throwing

```typescript
import { ApiErrorCode, throwApi } from 'src/common/errors';

throwApi(ApiErrorCode.ORDER_NOT_FOUND, {
  debug: `orderId=${orderId}`,
});
```

## Examples by category

| Code | HTTP | debug (example) |
|------|------|----------------|
| `AUTH_UNAUTHORIZED` | 401 | JWT missing or invalid |
| `AUTH_INVALID_OTP` | 400 | OTP bcrypt mismatch |
| `VALIDATION_FILE_TOO_LARGE` | 400 | File exceeds 10MB |
| `WS_TOO_MANY_CONNECTIONS` | — | WS handshake |
| `DEVICE_OFFLINE` | 400 | No active websocket session |
| `INTERNAL_ERROR` | 500 | Unhandled exception |

## Migration

1. Import `throwApi` / `ApiException` in service.
2. Replace `BadRequestException('English')`.
3. Add legacy mapping in `legacy-message-map.ts` until call site is updated.
4. Remove mapping when complete.

See `src/common/errors/` for implementation.
