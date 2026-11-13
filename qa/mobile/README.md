# Flutter / Mobile QA (my_auto)

## Stack detected

- Flutter app: `my_auto/`
- Unit/widget: `flutter_test` (already in `pubspec.yaml`)
- Existing tests: `my_auto/test/`
- State: `flutter_bloc` + `provider`
- Navigation: `go_router`
- API: `graphql_flutter`

## Framework choices

| Tool | Status | Notes |
|------|--------|-------|
| `flutter_test` | Configured | Primary unit/widget tests |
| `integration_test` | Scaffolded under `qa/mobile/integration_test` (copy into app when ready) | Flutter official |
| **Patrol** | Recommended for Flutter native UI | Requires `patrol` + Android/iOS native hooks — install only when ready to modify platform folders |
| **Maestro** | Configured (YAML flows) | Lowest friction; needs Maestro CLI + built APK/IPA |
| Appium / Detox | Not selected | Detox is RN-focused; Appium heavier than needed |

## Commands

```bash
# From repo root
npm run qa:flutter
npm run qa:flutter:analyze

# Direct
cd my_auto && flutter test
cd my_auto && flutter analyze
```

## Maestro

Install CLI separately: https://maestro.mobile.dev/

```bash
maestro test qa/mobile/maestro/smoke-launch.yaml
```

Flows assume a debug/release APK already installed or launched via `maestro`.

## Patrol (optional manual setup)

```bash
cd my_auto
flutter pub add dev:patrol
# then follow Patrol 4.x native setup for Android/iOS
```

Do **not** run Patrol install automatically against production devices without consent.
