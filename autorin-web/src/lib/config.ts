/** Backend origin or `…/api`. Trailing `/api` is normalized below. */
const rawApiUrl = (import.meta.env.VITE_API_URL ?? "http://localhost:7007").replace(
  /\/$/,
  "",
);

/** Server origin without `/api` — REST uploads, media proxy, health. */
export const API_ORIGIN = rawApiUrl.replace(/\/api$/i, "");

/**
 * Preferred API base for display / legacy callers.
 * May still include `/api` if set that way in env; prefer `API_ORIGIN` + path.
 */
export const API_URL = rawApiUrl;

export const FILE_URL = import.meta.env.VITE_FILE_URL ?? rawApiUrl;

/** GraphQL HTTP endpoint (always `ORIGIN/api`). */
export const GRAPHQL_URL = `${API_ORIGIN}/api`;
