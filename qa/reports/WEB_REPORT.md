# Web QA Report — AutoRin (`autorin-web`)

**Date:** 2026-11-13  
**Target:** `http://127.0.0.1:5173` (Vite; Playwright `webServer` / local)  
**Browser:** Chromium (Playwright 1.65.0)

## Executed suite

```text
npx playwright test --project=chromium
```

**Result: 16 passed, 3 failed (3.6m)**  
Raw: `qa/reports/web-playwright-raw.txt`  
Artifacts: `qa/screenshots/playwright-artifacts/`

## Passed (executed)

- Invalid credentials stay on `/sign-in` (do not enter admin)
- Unauth guards for `/admin`, `/admin/products`, `/admin/orders`, `/admin/moderation`, `/admin/messages`, `/admin/settings`, `/moderator`
- Navigation: `/` leaves bare root; `/signup` → `/sign-in`
- Smoke sign-in render / empty submit / admin redirect
- Network failure: GraphQL abort — page stays on sign-in (no white-screen crash)
- Responsive screenshots: mobile + tablet

## Failed

| Test | Failure | Classification |
|------|---------|----------------|
| Audit: sign-in reachable | `page.goto` timeout 30s waiting for `load` | Flaky under 6-worker load / splash |
| Unauth `/admin/users` | same goto timeout | Same |
| Responsive desktop sign-in | same goto timeout | Same |

Sibling routes and smoke sign-in **passed** in the same run → treat as **reliability / performance under parallel load**, not confirmed auth bypass. Screenshots/videos retained under `qa/screenshots/playwright-artifacts/`.

### BUG-008 — Web E2E flaky navigation timeouts — **Medium**
- **Module:** Web QA / Vite under parallel Playwright
- **Expected:** Stable `<30s` navigation
- **Actual:** Intermittent `page.goto` load timeouts (~50–70s tests also seen when passing)
- **Suggested fix:** Raise navigation timeout; `workers: 2`; `waitUntil: 'domcontentloaded'`; reduce 3.2s splash in test builds (app change needs approval)

## Auth / UI observations

- `AdminLayout` returns `null` then navigates to sign-in when unauthenticated — brief blank frame possible (**Low** UX, not confirmed data leak; guarded queries use `skip: !isAdmin(user)`).
- Splash (~3200ms) slows every E2E navigation.

## Dependency security (web)

`npm audit --omit=dev` on `autorin-web`: **2 vulnerabilities** (react-router / react-router-dom — High/Moderate advisories). See SECURITY_REPORT.

## Gaps

- Authenticated admin CRUD (products, orders, users, moderation) — **BLOCKED** without test admin credentials
- Cross-browser Firefox/WebKit — not executed this audit (Chromium only)
- axe accessibility deep audit — not executed

## Web verdict
**Smoke + unauth guards largely healthy.** Release still blocked by dependency advisories and need for authenticated journey coverage.
