/**
 * Allow only same-app relative paths (no protocol-relative / backslash open redirects).
 */
export function safeInternalRedirect(
  candidate: string | null | undefined,
  fallback: string,
  allowedPrefixes: string[],
): string {
  const raw = (candidate ?? '').trim();
  if (!raw.startsWith('/') || raw.startsWith('//') || raw.includes('\\')) {
    return fallback;
  }
  if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(raw)) {
    return fallback;
  }
  if (allowedPrefixes.some((p) => raw === p || raw.startsWith(`${p}/`) || raw.startsWith(`${p}?`))) {
    return raw;
  }
  return fallback;
}
