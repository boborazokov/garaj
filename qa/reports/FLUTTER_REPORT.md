# Flutter QA Report — `my_auto`

**Date:** 2026-11-13  
**Host:** Windows; device `flutter run` was active on Android during audit  
**Rules:** No app source edits

## Executed

| Check | Result | Evidence |
|-------|--------|----------|
| `flutter test` | **FAIL** — 8 passed, 1 failed | `qa/reports/flutter-test-raw.txt` |
| `flutter analyze` | **PASS_WITH_NOTES** — 154 issues (info/warning) | `qa/reports/flutter-analyze-raw.txt` |
| Maestro flows | **BLOCKED** — Maestro CLI not installed | `qa/mobile/maestro/` |
| Patrol | **BLOCKED** — not installed (opt-in) | `qa/mobile/README.md` |
| iOS simulator | **BLOCKED** — Windows host | |

## Passing unit tests (executed)

- `test/auth_session_test.dart` — refresh token / accessToken legacy mapping
- `test/core/auth/auth_token_store_test.dart`
- `test/core/auth/refresh_single_flight_test.dart`
- (plus other non-widget tests totaling 8 green)

## BUG-007 — Stale counter `widget_test.dart` (separate investigation)

- **Severity:** Medium  
- **Module:** Flutter tests  
- **Steps:** `flutter test test/widget_test.dart`  
- **Expected:** Valid smoke for AutoRin  
- **Actual:** Asserts counter `0` / `Icons.add` against full `MyApp()` marketplace shell → finder fails; additional framework exceptions while pumping real GraphQL/provider tree without test doubles  
- **Evidence:** expanded test log; file still Flutter-create template  
- **Suggested fix:** Replace/delete template; add harnessed smoke with mocks  
- Full write-up: `qa/bug-reports/BUG-007-flutter-widget-test-stale.md`

## Analyze notes

154 analyzer findings dominated by generated `intl` dependency infos and deprecated `withOpacity` usages. No new crash signature proven beyond test harness noise. Treat as tech debt, not P0 product bugs, unless CI treats warnings as errors.

## Runtime / integration risks (observed config, not device crash reproduced)

### BUG-011 — Mobile API host hard-coded to LAN IP — **Medium**
- **Module:** Flutter config (`my_auto/.env`, gitignored)
- **Actual:** `API_URL` / `API_File_URL` point at a LAN IP (host redacted), not localhost
- **Risk:** Device works only on that LAN; web uses Vite same-origin proxy — cross-platform env drift
- **Evidence:** dotenv keys present; GraphQL client reads `dotenv.env['API_URL']`
- **Suggested fix:** Document per-developer `.env.example`; optional debug switch; CI emulator uses `10.0.2.2:7007`

### Mobile E2E
Login / navigation / offline / permissions / deep links: **BLOCKED** for automated evidence this session (no Maestro/Patrol). Manual `flutter run` session was active but not used as automated pass evidence.

## Flutter verdict
**Not green.** Fix or quarantine BUG-007 before relying on CI. Expand widget/integration coverage for auth screens after harness exists.
