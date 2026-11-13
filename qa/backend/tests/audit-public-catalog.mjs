#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const url = 'http://127.0.0.1:7007/api';
const out = path.resolve(__dirname, '../../reports/backend-public-catalog.json');

const queries = [
  {
    name: 'getParts-unauth',
    query: `query { getParts(pagination: { page: 1, limit: 2 }) { page payload { _id } } }`,
  },
  {
    name: 'getCategories-unauth',
    query: `query { getCategories { _id names { uz } } }`,
  },
  {
    name: 'getAdminStats-unauth',
    query: `query { getAdminStats { usersCount } }`,
  },
];

const results = [];
for (const q of queries) {
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ query: q.query }),
      signal: AbortSignal.timeout(10000),
    });
    const body = await res.json();
    const hasPayload = body?.data && Object.values(body.data).some((v) => v != null);
    results.push({
      name: q.name,
      status: res.status,
      hasData: !!hasPayload,
      hasErrors: Array.isArray(body.errors) && body.errors.length > 0,
      errorCodes: (body.errors || []).map((e) => e.extensions?.code || e.message),
      exposesStacktrace: JSON.stringify(body).includes('stacktrace'),
    });
  } catch (err) {
    results.push({ name: q.name, status: 'BLOCKED', error: String(err.message || err) });
  }
}

fs.writeFileSync(out, JSON.stringify({ generatedAt: new Date().toISOString(), results }, null, 2));
console.log(JSON.stringify(results, null, 2));
