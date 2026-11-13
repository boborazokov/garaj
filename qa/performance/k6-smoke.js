/**
 * k6 smoke — GraphQL endpoint latency.
 * Install k6 separately: https://k6.io/docs/get-started/installation/
 * Run: k6 run qa/performance/k6-smoke.js
 * Target only local/staging (QA_API_BASE_URL).
 */
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 2,
  duration: '15s',
  thresholds: {
    http_req_failed: ['rate<0.05'],
    http_req_duration: ['p(95)<2000'],
  },
};

const base = __ENV.QA_API_BASE_URL || 'http://127.0.0.1:7007';
const path = __ENV.QA_GRAPHQL_PATH || '/api';

export default function () {
  const res = http.post(
    `${base}${path}`,
    JSON.stringify({ query: '{ __typename }' }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  sleep(1);
}
