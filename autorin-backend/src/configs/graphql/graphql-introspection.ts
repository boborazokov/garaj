/**
 * GraphQL introspection policy.
 *
 * Production: always disabled — env cannot re-enable it.
 * Non-production: GRAPHQL_INTROSPECTION=true|1 enables; false|0 disables;
 * unset defaults to enabled (local schema tooling).
 */
export function resolveGraphqlIntrospection(
  isProduction: boolean,
  explicit?: string | null,
): boolean {
  if (isProduction) {
    return false;
  }

  const raw = (explicit ?? '').trim().toLowerCase();
  if (raw === '1' || raw === 'true') {
    return true;
  }
  if (raw === '0' || raw === 'false') {
    return false;
  }
  return true;
}
