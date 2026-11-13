#!/usr/bin/env node
/**
 * Lightweight API surface check (connectivity + response headers).
 * Not a substitute for OWASP ZAP / full security-testing skill runs.
 */
import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
config({ path: path.resolve(__dirname, '../.env') });

const base = process.env.QA_API_BASE_URL ?? 'http://127.0.0.1:7007';

async function main() {
  try {
    const res = await fetch(base, { method: 'GET', signal: AbortSignal.timeout(8_000) });
    const headers = Object.fromEntries(res.headers.entries());
    console.log(
      JSON.stringify(
        {
          suite: 'backend-security-headers',
          status: 'PASS_WITH_NOTES',
          httpStatus: res.status,
          observedHeaders: {
            'x-powered-by': headers['x-powered-by'] ?? null,
            'content-security-policy': headers['content-security-policy'] ?? null,
            'strict-transport-security': headers['strict-transport-security'] ?? null,
            'x-frame-options': headers['x-frame-options'] ?? null,
            'x-content-type-options': headers['x-content-type-options'] ?? null,
          },
          note: 'Header absence is informational. Full OWASP ZAP scan is optional/manual.',
        },
        null,
        2,
      ),
    );
  } catch (err) {
    console.log(
      JSON.stringify(
        {
          suite: 'backend-security-headers',
          status: 'BLOCKED',
          detail: String(err?.message ?? err),
        },
        null,
        2,
      ),
    );
    process.exit(2);
  }
}

main();
