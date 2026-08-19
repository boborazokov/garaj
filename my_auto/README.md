# Garage (Flutter)

Marketplace for auto parts, buy requests, workshops, services, and chat.

**Version:** 1.0.1+1 · **SDK:** Flutter 3.5+

## Quick start

```bash
flutter pub get
# copy .env.example to .env and set API_URL
flutter run
```

## Documentation

| Doc | Description |
|-----|-------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | App structure & migration |
| [docs/AUTH_FLOW.md](docs/AUTH_FLOW.md) | Access/refresh lifecycle |
| [docs/WS_AUTH.md](docs/WS_AUTH.md) | WebSocket auth |
| [docs/SECURITY_REPORT.md](docs/SECURITY_REPORT.md) | Risks & hardening |
| [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md) | Env variables |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Release process |
| [docs/backend/nestjs-auth-reference/](docs/backend/nestjs-auth-reference/) | Backend auth spec |

## Stack

- GraphQL + graphql-ws
- Provider + Bloc
- go_router
- Firebase Messaging
- flutter_secure_storage

## Auth (client)

Production auth is centralized in `lib/core/auth/auth_coordinator.dart`:

- Memory + secure storage sync
- `TOKEN_EXPIRED` → refresh → retry
- Protected GraphQL requires Bearer
- WebSocket requires valid access token

**Requires backend** `refreshSession`, `logoutSession`, and session collection — see docs above.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Unauthorized after login | Hot restart; ensure `establishSession` completes |
| WS not connecting | Check access token; guest has no subscriptions |
| Catalog empty in create order | Seed brands/models/PART categories on API |
| Device cannot reach API | Use host machine LAN IP in `.env`, not `localhost` |

## License

Proprietary — Garage.
