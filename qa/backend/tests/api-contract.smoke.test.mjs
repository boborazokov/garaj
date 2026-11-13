import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { INTROSPECTION_LITE, SIGN_IN } from '../fixtures/graphql-queries.mjs';

describe('GraphQL fixtures contract', () => {
  it('exports introspection query', () => {
    assert.match(INTROSPECTION_LITE, /__typename/);
  });

  it('exports signIn query with variables', () => {
    assert.match(SIGN_IN, /signIn/);
    assert.match(SIGN_IN, /\$data/);
  });
});
