/**
 * Keys whose values must never appear in logs (case-insensitive).
 * Matches common auth/session/secret field names including OTP.
 */
export const SENSITIVE_LOG_KEY =
  /^(otp|code|password|passwd|authorization|access[_-]?token|refresh[_-]?token|token|secret|cookie|set-cookie|api[_-]?key|jwt|bearer)$/i;

const REDACTED = '[redacted]';

export function sanitizeForLog(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => sanitizeForLog(item));
  }

  if (value && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const [key, nested] of Object.entries(
      value as Record<string, unknown>,
    )) {
      if (SENSITIVE_LOG_KEY.test(key)) {
        out[key] = REDACTED;
      } else {
        out[key] = sanitizeForLog(nested);
      }
    }
    return out;
  }

  return value;
}

/** Convenience for Nest Logger payloads that should always be objects. */
export function sanitizeForLogObject(
  payload: Record<string, unknown>,
): Record<string, unknown> {
  return sanitizeForLog(payload) as Record<string, unknown>;
}
