import { createHash } from 'crypto';

export const OTP_MAX_ATTEMPTS = 5;
export const OTP_WINDOW_MS = 5 * 60 * 1000;

export class OtpStoreUnavailableError extends Error {
  constructor() {
    super('OTP store unavailable');
  }
}

export interface OtpCounterStore {
  get(key: string): Promise<number>;
  /** Atomic increment. The first hit sets the TTL. */
  increment(key: string, ttlMs: number): Promise<number>;
  /** True only the first time this key is consumed before the TTL. */
  consumeOnce(key: string, ttlMs: number): Promise<boolean>;
}

export class MemoryOtpCounterStore implements OtpCounterStore {
  private readonly values = new Map<string, { count: number; until: number }>();
  private readonly consumed = new Map<string, number>();

  async get(key: string): Promise<number> {
    const current = this.values.get(key);
    if (!current || current.until <= Date.now()) return 0;
    return current.count;
  }

  async increment(key: string, ttlMs: number): Promise<number> {
    const now = Date.now();
    const current = this.values.get(key);
    if (!current || current.until <= now) {
      this.values.set(key, { count: 1, until: now + ttlMs });
      return 1;
    }
    current.count += 1;
    return current.count;
  }

  async consumeOnce(key: string, ttlMs: number): Promise<boolean> {
    const now = Date.now();
    const until = this.consumed.get(key) ?? 0;
    if (until > now) return false;
    this.consumed.set(key, now + ttlMs);
    return true;
  }
}

export function otpTokenKey(token: string, kind: 'attempts' | 'used'): string {
  const hash = createHash('sha256').update(token).digest('hex');
  return `otp:${kind}:${hash}`;
}

/** Shared OTP brute-force gate. Store errors fail closed. */
export class OtpProtection {
  constructor(private readonly store: OtpCounterStore) {}

  async assertAllowed(token: string): Promise<boolean> {
    const count = await this.guard(() =>
      this.store.get(otpTokenKey(token, 'attempts')),
    );
    return count < OTP_MAX_ATTEMPTS;
  }

  async recordFailure(token: string): Promise<number> {
    return this.guard(() =>
      this.store.increment(otpTokenKey(token, 'attempts'), OTP_WINDOW_MS),
    );
  }

  /** Marks a confirmation token single-use. False if it was already used. */
  async consume(token: string): Promise<boolean> {
    return this.guard(() =>
      this.store.consumeOnce(otpTokenKey(token, 'used'), OTP_WINDOW_MS),
    );
  }

  private async guard<T>(op: () => Promise<T>): Promise<T> {
    try {
      return await op();
    } catch (err) {
      if (err instanceof OtpStoreUnavailableError) throw err;
      throw new OtpStoreUnavailableError();
    }
  }
}
