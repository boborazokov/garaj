import { createHash, randomBytes } from 'crypto';
import type { SignOptions } from 'jsonwebtoken';

/** Old access tokens without `sid` stay valid only until this instant. */
export const DEFAULT_LEGACY_ACCESS_UNTIL = '2026-11-16T00:00:00.000Z';

export const REFRESH_REUSE_GRACE_MS = 15_000;

export type SessionSnapshot = {
  currentHash: string;
  previousHash?: string | null;
  expiresAt: Date;
  revokedAt?: Date | null;
  rotatedAt?: Date | null;
};

export type RefreshDecision =
  | { type: 'rotate' }
  | { type: 'conflict' }
  | { type: 'reuse' }
  | { type: 'expired' }
  | { type: 'revoked' }
  | { type: 'invalid' };

export function hashRefreshToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export function newRefreshToken(): string {
  return randomBytes(32).toString('base64url');
}

export function signAccessToken(
  payload: Record<string, unknown>,
  secret: string,
  expiresIn: string,
  sign: (
    payload: Record<string, unknown>,
    secret: string,
    options: SignOptions,
  ) => string,
  decode: typeof import('jsonwebtoken').decode,
): string {
  const token = sign(payload, secret, {
    expiresIn: expiresIn as SignOptions['expiresIn'],
  });
  const decoded = decode(token);
  if (!decoded || typeof decoded === 'string' || !decoded.exp) {
    throw new Error('Access token must expire');
  }
  return token;
}

export function decideRefresh(
  session: SessionSnapshot | null,
  presentedHash: string,
  now: number,
  graceMs = REFRESH_REUSE_GRACE_MS,
): RefreshDecision {
  if (!session) return { type: 'invalid' };
  if (session.revokedAt) return { type: 'revoked' };
  if (session.expiresAt.getTime() <= now) return { type: 'expired' };

  if (session.currentHash === presentedHash) return { type: 'rotate' };

  if (session.previousHash === presentedHash) {
    const rotatedAt = session.rotatedAt?.getTime() ?? 0;
    if (now - rotatedAt <= graceMs) return { type: 'conflict' };
    return { type: 'reuse' };
  }

  return { type: 'invalid' };
}

/**
 * Tokens minted before sessions have no `sid` and no `exp`.
 * They are accepted only until the cutoff, then rejected.
 */
export function legacyAccessStillValid(
  payload: { sid?: string; exp?: number },
  now: number,
  legacyUntilMs: number,
): boolean {
  if (payload.sid || payload.exp) return false;
  return now < legacyUntilMs;
}
