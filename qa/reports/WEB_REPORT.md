# Web QA Report — post-fix

## Results

| Suite | Result | Evidence |
|-------|--------|----------|
| Playwright chromium | **PASS** 19/19 | `postfix-playwright.txt` |
| `vite build` / `tsc -b` | **PASS** | `postfix-web-build.txt` |
| safe-redirect unit | **PASS** | `node --test qa/web/tests/unit/safe-redirect.node.test.mjs` |

## Fixes
- BUG-001: removed `correctCode` from `SIGN_UP`
- BUG-006: `react-router-dom@7.18.5`, `safeInternalRedirect` on sign-in
- BUG-008: `domcontentloaded`, workers=3, nav timeout 45s

## Residual
`npm audit` may still list react-router advisories despite installed `7.18.5` (patched past `7.18.1` range). App-level open-redirect hardening in place.
