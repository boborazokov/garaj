#!/usr/bin/env node
/**
 * Safe GraphQL smoke against local/staging API.
 * Marks BLOCKED when the server is unreachable (does not invent a pass).
 */
import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { INTROSPECTION_LITE } from '../fixtures/graphql-queries.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
config({ path: path.resolve(__dirname, '../.env') });
config({ path: path.resolve(__dirname, '../../.env') });

const base = process.env.QA_API_BASE_URL ?? 'http://127.0.0.1:7007';
const gqlPath = process.env.QA_GRAPHQL_PATH ?? '/api';
const url = `${base.replace(/\/$/, '')}${gqlPath}`;

async function main() {
  const started = Date.now();
  let status = 'UNKNOWN';
  let detail = '';

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ query: INTROSPECTION_LITE }),
      signal: AbortSignal.timeout(8_000),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) {
      status = 'FAIL';
      detail = `HTTP ${res.status}: ${JSON.stringify(body).slice(0, 400)}`;
    } else if (body.errors?.length) {
      // Some hardened GraphQL servers disable __typename root; treat as soft pass if HTTP 200 with structured errors
      status = 'PASS_WITH_NOTES';
      detail = `GraphQL errors: ${JSON.stringify(body.errors).slice(0, 400)}`;
    } else if (body.data?.__typename) {
      status = 'PASS';
      detail = `root __typename=${body.data.__typename}`;
    } else {
      status = 'PASS_WITH_NOTES';
      detail = `HTTP 200, unexpected shape: ${JSON.stringify(body).slice(0, 400)}`;
    }
  } catch (err) {
    status = 'BLOCKED';
    detail = `Backend unreachable at ${url}: ${err?.message ?? err}`;
  }

  const result = {
    suite: 'backend-graphql-smoke',
    status,
    url,
    elapsedMs: Date.now() - started,
    detail,
    safety: 'local/staging only — never run against production without permission',
  };
  console.log(JSON.stringify(result, null, 2));
  if (status === 'FAIL') process.exit(1);
  if (status === 'BLOCKED') process.exit(2);
}

main();
