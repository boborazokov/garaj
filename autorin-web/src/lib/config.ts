/**
 * Backend origin or `…/api`. Trailing `/api` is normalized below.
 * Dev default is same-origin (`""`) so LAN/phone can use the Vite proxy
 * instead of a hardcoded localhost IP that only works on this machine.
 */
const envApi = (import.meta.env.VITE_API_URL as string | undefined)?.trim();
const rawApiUrl = (
  envApi && envApi.length > 0
    ? envApi
    : import.meta.env.DEV
      ? ""
      : "http://localhost:7007"
).replace(/\/$/, "");

/** Server origin without `/api` — REST uploads, media proxy, health. */
export const API_ORIGIN = rawApiUrl.replace(/\/api$/i, "");

/**
 * Preferred API base for display / legacy callers.
 * May still include `/api` if set that way in env; prefer `API_ORIGIN` + path.
 */
export const API_URL = rawApiUrl;

const envFile = (import.meta.env.VITE_FILE_URL as string | undefined)?.trim();
export const FILE_URL =
  envFile && envFile.length > 0
    ? envFile.replace(/\/$/, "")
    : API_ORIGIN;

/** GraphQL HTTP endpoint (always `ORIGIN/api`, or relative `/api` in dev). */
export const GRAPHQL_URL = API_ORIGIN ? `${API_ORIGIN}/api` : "/api";
