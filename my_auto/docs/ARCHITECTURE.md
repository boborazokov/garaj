# Architecture — My Auto (Flutter client)

## Layers (target standard)

```
features/<feature>/
  presentation/   # screens, widgets, bloc/cubit
  domain/         # entities, repository interfaces, use cases
  data/           # dto, datasources, repository impl
core/             # auth, graphql, theme, shared utils
```

## Current state (hybrid)

| Feature | Pattern |
|---------|---------|
| orders | Bloc + repository ✅ |
| create_product | Bloc + repository ✅ |
| chat | repository + local cache |
| notifications | Bloc + PushService |
| home, profile, add | Provider + GraphQL (legacy) |

## API layer

- Single GraphQL endpoint: `{API_URL}/api`  
- Link chain: `AuthRefreshLink` → `SessionAuthLink` → `ErrorLink` → `HttpLink`  
- Subscriptions: `WebSocketAuthGateLink` → `WebSocketLink`  

## Auth single source of truth

`AuthCoordinator` (logic) + `AuthProvider` (ChangeNotifier for UI)

## Migration plan (10 weeks sketch)

| Week | Task |
|------|------|
| 1–2 | Backend sessions + refresh (P0) |
| 3 | Flutter auth E2E against staging |
| 4 | Migrate `OrdersProvider` consumers → existing Bloc |
| 5–6 | Unify create product (remove `add/addProduct`) |
| 7 | Encrypt chat DB + logout wipe |
| 8 | Sentry + structured logging |
| 9 | GraphQL security tests |
| 10 | Production checklist sign-off |

## Feature modules

- **home** — catalog feed, categories  
- **search** — unified search hub  
- **orders** — buy requests marketplace  
- **create_product** — seller listing wizard  
- **workshop** / **services** / **map** — discovery  
- **chat** — buyer/seller messaging  
- **auth** — sign-up, OTP, sign-in  
- **profile** — account management  
