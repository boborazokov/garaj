/**
 * Mirrors autorin-backend resolveGraphqlIntrospection policy for QA evidence
 * without requiring a production NODE_ENV process.
 */
import assert from 'node:assert/strict';
import test from 'node:test';

function resolveGraphqlIntrospection(isProduction, explicit) {
  if (isProduction) {
    return false;
  }
  const raw = (explicit ?? '').trim().toLowerCase();
  if (raw === '1' || raw === 'true') return true;
  if (raw === '0' || raw === 'false') return false;
  return true;
}

test('production + GRAPHQL_INTROSPECTION=true → disabled', () => {
  assert.equal(resolveGraphqlIntrospection(true, 'true'), false);
});

test('production + GRAPHQL_INTROSPECTION=false → disabled', () => {
  assert.equal(resolveGraphqlIntrospection(true, 'false'), false);
});

test('development + GRAPHQL_INTROSPECTION=true → enabled', () => {
  assert.equal(resolveGraphqlIntrospection(false, 'true'), true);
});
