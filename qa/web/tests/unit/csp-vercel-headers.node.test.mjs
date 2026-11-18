import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const vercelPath = path.resolve(
  __dirname,
  '../../../../autorin-web/vercel.json',
);

test('vercel.json defines CSP Report-Only and baseline security headers', () => {
  const vercel = JSON.parse(fs.readFileSync(vercelPath, 'utf8'));
  const headers = vercel.headers?.[0]?.headers ?? [];
  const map = Object.fromEntries(headers.map((h) => [h.key, h.value]));

  assert.equal(map['X-Content-Type-Options'], 'nosniff');
  assert.equal(map['X-Frame-Options'], 'DENY');
  assert.equal(map['Referrer-Policy'], 'no-referrer');
  assert.ok(
    map['Content-Security-Policy-Report-Only'],
    'expected Content-Security-Policy-Report-Only',
  );

  const csp = map['Content-Security-Policy-Report-Only'];
  assert.match(csp, /default-src 'self'/);
  assert.match(csp, /frame-ancestors 'none'/);
  assert.match(csp, /script-src 'self'/);
  assert.match(csp, /fonts\.googleapis\.com/);
  assert.match(csp, /fonts\.gstatic\.com/);
  assert.match(csp, /autorin-backend\.onrender\.com/);
  assert.doesNotMatch(csp, /default-src \*/);
});
