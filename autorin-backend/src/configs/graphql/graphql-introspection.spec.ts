import { resolveGraphqlIntrospection } from './graphql-introspection';

describe('resolveGraphqlIntrospection', () => {
  it('disables introspection in production even when GRAPHQL_INTROSPECTION=true', () => {
    expect(resolveGraphqlIntrospection(true, 'true')).toBe(false);
    expect(resolveGraphqlIntrospection(true, '1')).toBe(false);
  });

  it('disables introspection in production when GRAPHQL_INTROSPECTION=false', () => {
    expect(resolveGraphqlIntrospection(true, 'false')).toBe(false);
    expect(resolveGraphqlIntrospection(true, '0')).toBe(false);
  });

  it('disables introspection in production when env is unset', () => {
    expect(resolveGraphqlIntrospection(true, undefined)).toBe(false);
    expect(resolveGraphqlIntrospection(true, null)).toBe(false);
    expect(resolveGraphqlIntrospection(true, '')).toBe(false);
  });

  it('enables introspection in development when GRAPHQL_INTROSPECTION=true', () => {
    expect(resolveGraphqlIntrospection(false, 'true')).toBe(true);
    expect(resolveGraphqlIntrospection(false, '1')).toBe(true);
  });

  it('disables introspection in development when GRAPHQL_INTROSPECTION=false', () => {
    expect(resolveGraphqlIntrospection(false, 'false')).toBe(false);
    expect(resolveGraphqlIntrospection(false, '0')).toBe(false);
  });

  it('defaults to enabled in development when unset', () => {
    expect(resolveGraphqlIntrospection(false, undefined)).toBe(true);
  });
});
