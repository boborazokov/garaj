# BUG-007 — Stale `widget_test.dart` counter template fails

- **Severity:** Medium (blocks green `flutter test` / CI)
- **Module:** Flutter (`my_auto/test/widget_test.dart`)
- **Status:** Reproduced; investigated separately; not fixed

## Reproduction
```bash
cd my_auto
flutter test test/widget_test.dart
```

## Expected
Smoke widget test matches real AutoRin app (boots without asserting a counter).

## Actual
Test pumps `MyApp()` then expects `find.text('0')` and `Icons.add` — Flutter create-template leftovers. App is a marketplace (`MyApp` uses GraphQL/providers/router), so finders fail:
`Expected: exactly one matching candidate … Found 0 widgets with text "0"`.

Secondary exception while building full app tree in test binding (provider/graphql dependencies) also observed in logs.

## Evidence
- `qa/reports/flutter-test-raw.txt`
- Suite result: **8 passed, 1 failed**
- File: `my_auto/test/widget_test.dart` L13–28

## Suggested fix (needs approval)
Replace with a minimal smoke that pumps a testable harness (mocked GraphQL/providers) **or** delete the template test and keep auth/session unit tests. Do not assert counter UI.
