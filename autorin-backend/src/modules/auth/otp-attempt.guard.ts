const MAX_ATTEMPTS = 5;
const WINDOW_MS = 5 * 60 * 1000;

/**
 * Caps OTP guesses for one confirmation token. The token itself stays valid
 * until it expires, so without this a caller can try all 100_000 codes.
 */
export class OtpAttemptGuard {
  private readonly failures = new Map<string, { count: number; until: number }>();

  assertAllowed(token: string, now = Date.now()) {
    const entry = this.failures.get(token);
    if (entry && entry.until > now && entry.count >= MAX_ATTEMPTS) {
      return false;
    }
    if (entry && entry.until <= now) {
      this.failures.delete(token);
    }
    return true;
  }

  recordFailure(token: string, now = Date.now()) {
    const current = this.failures.get(token);
    const count =
      current && current.until > now ? current.count + 1 : 1;
    this.failures.set(token, { count, until: now + WINDOW_MS });
    return count;
  }

  clear(token: string) {
    this.failures.delete(token);
  }
}
