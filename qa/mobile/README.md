# Flutter / Mobile QA (my_auto)

## Stack detected

- Flutter app: `my_auto/`
- Unit/widget: `flutter_test` (already in `pubspec.yaml`)
- Existing tests: `my_auto/test/`
- State: `flutter_bloc` + `provider`
- Navigation: `go_router`
- API: `graphql_flutter`

## API URL configuration (BUG-011)

Copy `my_auto/.env.example` → `my_auto/.env` (gitignored).

| Target | `API_URL` / `API_File_URL` |
|--------|---------------------------|
| Windows/macOS desktop | `http://127.0.0.1:7007` |
| Android emulator | `http://10.0.2.2:7007` |
| Physical device (LAN) | `http://<dev-machine-lan-ip>:7007` |
| iOS simulator | `http://127.0.0.1:7007` |

Web admin uses Vite same-origin proxy (`/api` → backend). Do not commit real LAN IPs or MapTiler keys.

## Framework choices

| Tool | Status | Notes |
|------|--------|-------|
| `flutter_test` | Configured | Primary unit/widget tests |
| `integration_test` | Scaffolded under `qa/mobile/integration_test` | Opt-in |
| **Patrol** | Optional | Needs native hooks |
| **Maestro** | YAML ready | Needs Maestro CLI |

## Commands

```bash
npm --prefix qa run qa:flutter
cd my_auto && flutter test
cd my_auto && flutter analyze
```
