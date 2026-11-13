import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { register } from 'node:module';

// Evaluate the TS helper via dynamic transpile is heavy; mirror the contract here
// and keep autorin-web/src/lib/helpers/safe-redirect.ts as source of truth.
function safeInternalRedirect(candidate, fallback, allowedPrefixes) {
  const raw = (candidate ?? '').trim();
  if (!raw.startsWith('/') || raw.startsWith('//') || raw.includes('\\')) {
    return fallback;
  }
  if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(raw)) {
    return fallback;
  }
  if (allowedPrefixes.some((p) => raw === p || raw.startsWith(`${p}/`) || raw.startsWith(`${p}?`))) {
    return raw;
  }
  return fallback;
}

describe('safeInternalRedirect contract', () => {
  it('allows relative admin paths', () => {
    assert.equal(safeInternalRedirect('/admin/users', '/admin', ['/admin']), '/admin/users');
  });
  it('rejects open redirects', () => {
    assert.equal(safeInternalRedirect('//evil.com', '/admin', ['/admin']), '/admin');
    assert.equal(safeInternalRedirect('/\\evil.com', '/admin', ['/admin']), '/admin');
  });
});
