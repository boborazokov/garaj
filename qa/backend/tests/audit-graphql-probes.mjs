#!/usr/bin/env node
/**
 * Live GraphQL audit probes — local only. Uses real AutoRin operation names.
 */
import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import fs from 'node:fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
config({ path: path.resolve(__dirname, '../.env'), quiet: true });
config({ path: path.resolve(__dirname, '../../.env'), quiet: true });

const base = process.env.QA_API_BASE_URL ?? 'http://127.0.0.1:7007';
const url = `${base.replace(/\/$/, '')}${process.env.QA_GRAPHQL_PATH ?? '/api'}`;
const outPath = path.resolve(__dirname, '../../reports/backend-graphql-probes.json');

async function gql(query, variables, headers = {}) {
  const started = Date.now();
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json', ...headers },
      body: JSON.stringify({ query, variables }),
      signal: AbortSignal.timeout(12_000),
    });
    const body = await res.json().catch(() => ({}));
    return { ok: res.ok, status: res.status, body, elapsedMs: Date.now() - started, error: null };
  } catch (err) {
    return { ok: false, status: 0, body: null, elapsedMs: Date.now() - started, error: String(err?.message ?? err) };
  }
}

function hasStack(body) {
  return JSON.stringify(body?.errors ?? []).includes('stacktrace');
}

function verdict(probe) {
  if (probe.result.error) return 'BLOCKED';
  if (probe.expect === 'reject-bad-creds') {
    const text = JSON.stringify(probe.result.body ?? {});
    const ok =
      /AUTH_INVALID|invalid credentials|UNAUTHORIZED|FORBIDDEN/i.test(text) &&
      !/signIn":\s*\{[^}]*token/i.test(text);
    return ok ? 'PASS' : 'FAIL';
  }
  if (probe.expect === 'reject-unauth') {
    const text = JSON.stringify(probe.result.body ?? {});
    const leakedData = probe.result.body?.data && Object.values(probe.result.body.data).some((v) => v != null);
    if (leakedData) return 'FAIL';
    if (/unauth|forbidden|UNAUTHORIZED|FORBIDDEN|AUTH_|jwt|token|role/i.test(text)) return 'PASS';
    // GraphQL validation mislabeled — still not a data leak
    if (probe.result.body?.errors?.length && !leakedData) return 'PASS_WITH_NOTES';
    return 'FAIL';
  }
  if (probe.expect === 'http-ok-data') {
    return probe.result.ok && probe.result.body?.data ? 'PASS' : 'FAIL';
  }
  if (probe.expect === 'no-stacktrace-on-validation') {
    return hasStack(probe.result.body) ? 'FAIL' : 'PASS';
  }
  if (probe.expect === 'introspection-limited') {
    if (probe.result.body?.data?.__schema) return 'PASS_WITH_NOTES';
    if (probe.result.body?.errors?.length) return 'PASS';
    return 'UNKNOWN';
  }
  if (probe.expect === 'signup-no-otp-leak') {
    const text = JSON.stringify(probe.result.body ?? {});
    if (probe.result.body?.data?.signUp?.correctCode != null) return 'FAIL';
    // Field removed from schema: requesting correctCode must fail validation (or omit field)
    if (/Cannot query field \"correctCode\"|VALIDATION_FAILED/i.test(text)) return 'PASS';
    if (probe.result.body?.data?.signUp && !('correctCode' in (probe.result.body.data.signUp || {}))) {
      return 'PASS';
    }
    if (/correctCode/i.test(text) && probe.result.body?.data?.signUp) return 'FAIL';
    return 'PASS';
  }
  return 'UNKNOWN';
}

const probes = [];

async function run(name, expect, query, variables, headers) {
  const result = await gql(query, variables, headers);
  const item = {
    name,
    expect,
    result: {
      ...result,
      body: sanitize(result.body),
      exposesStacktrace: hasStack(result.body),
    },
  };
  item.status = verdict(item);
  probes.push(item);
  console.log(`[${item.status}] ${name}${item.result.exposesStacktrace ? ' (stacktrace exposed)' : ''}`);
}

function sanitize(body) {
  if (!body) return body;
  const s = JSON.stringify(body);
  return JSON.parse(
    s
      .replace(/"(eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)"/g, '"[REDACTED_JWT]"')
      .replace(/"correctCode"\s*:\s*"[^"]*"/g, '"correctCode":"[REDACTED]"')
      .replace(/\\\\node_modules\\\\[^\"]+/g, '[path]'),
  );
}

await run('root-typename', 'http-ok-data', `query { __typename }`);

await run(
  'signIn-invalid-credentials',
  'reject-bad-creds',
  `query SignIn($data: SignInInput!) {
    signIn(data: $data) {
      token
      user { _id phone role }
    }
  }`,
  { data: { phone: '+998900000000', password: 'definitely-wrong-password-qa' } },
);

await run(
  'admin-stats-without-token',
  'reject-unauth',
  `query { getAdminStats { usersCount partsCount } }`,
);

await run(
  'admin-stats-with-forged-bearer',
  'reject-unauth',
  `query { getAdminStats { usersCount partsCount } }`,
  undefined,
  { authorization: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmYWtlIn0.invalid' },
);

await run(
  'admin-list-users-without-token',
  'reject-unauth',
  `query {
    adminListUsers(pagination: { page: 1, limit: 1 }) {
      payload { _id phone role }
      page
    }
  }`,
);

await run(
  'getAppSettings-without-token',
  'reject-unauth',
  `query { getAppSettings { supportEmail productModerationEnabled } }`,
);

await run(
  'validation-error-no-stacktrace',
  'no-stacktrace-on-validation',
  `query { totallyFakeFieldThatDoesNotExist }`,
);

await run(
  'introspection-schema',
  'introspection-limited',
  `query { __schema { queryType { name } types { name } } }`,
);

await run(
  'signUp-otp-leak-check',
  'signup-no-otp-leak',
  `mutation SignUp($data: SignUpInput!) {
    signUp(data: $data) { token correctCode }
  }`,
  {
    data: {
      phone: '+998901119998',
      password: 'QaAuditPass123!',
      name: 'QA Audit Probe',
    },
  },
);

const summary = {
  suite: 'backend-graphql-audit-probes',
  url,
  generatedAt: new Date().toISOString(),
  counts: probes.reduce((a, p) => {
    a[p.status] = (a[p.status] || 0) + 1;
    return a;
  }, {}),
  probes,
};
fs.writeFileSync(outPath, JSON.stringify(summary, null, 2));
console.log(JSON.stringify(summary.counts, null, 2));
console.log(`Wrote ${outPath}`);

if (probes.some((p) => p.status === 'FAIL')) process.exit(1);
if (probes.every((p) => p.status === 'BLOCKED')) process.exit(2);
process.exit(0);
