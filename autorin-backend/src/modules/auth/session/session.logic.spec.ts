import {
  decideRefresh,
  legacyAccessStillValid,
  REFRESH_REUSE_GRACE_MS,
  signAccessToken,
} from './session.logic';
import * as jwt from 'jsonwebtoken';

const now = 1_700_000_000_000;

function session(overrides: Partial<Parameters<typeof decideRefresh>[0]> = {}) {
  return {
    currentHash: 'current',
    previousHash: null,
    expiresAt: new Date(now + 60_000),
    revokedAt: null,
    rotatedAt: null,
    ...overrides,
  };
}

describe('decideRefresh', () => {
  it('rotates the current token', () => {
    expect(decideRefresh(session(), 'current', now).type).toBe('rotate');
  });

  it('rejects an expired or revoked session', () => {
    expect(
      decideRefresh(session({ expiresAt: new Date(now - 1) }), 'current', now)
        .type,
    ).toBe('expired');
    expect(
      decideRefresh(session({ revokedAt: new Date(now) }), 'current', now).type,
    ).toBe('revoked');
  });

  it('treats a just-rotated token as a conflict, then as reuse', () => {
    const rotated = session({
      previousHash: 'old',
      rotatedAt: new Date(now - 1_000),
    });
    expect(decideRefresh(rotated, 'old', now).type).toBe('conflict');
    expect(
      decideRefresh(
        session({
          previousHash: 'old',
          rotatedAt: new Date(now - REFRESH_REUSE_GRACE_MS - 1),
        }),
        'old',
        now,
      ).type,
    ).toBe('reuse');
  });

  it('rejects an unknown token', () => {
    expect(decideRefresh(session(), 'other', now).type).toBe('invalid');
    expect(decideRefresh(null, 'current', now).type).toBe('invalid');
  });
});

describe('legacyAccessStillValid', () => {
  const until = now + 1_000;

  it('allows a token with no sid and no exp before the cutoff', () => {
    expect(legacyAccessStillValid({}, now, until)).toBe(true);
  });

  it('rejects a legacy token at the cutoff and accepts one millisecond before', () => {
    const until = Date.parse('2026-11-16T00:00:00.000Z');
    expect(legacyAccessStillValid({}, until - 1, until)).toBe(true);
    expect(legacyAccessStillValid({}, until, until)).toBe(false);
    expect(legacyAccessStillValid({}, until + 1, until)).toBe(false);
  });

  it('does not treat an empty session id as a bypass after the cutoff', () => {
    const until = Date.parse('2026-11-16T00:00:00.000Z');
    expect(legacyAccessStillValid({ sid: '' }, until + 1, until)).toBe(false);
  });

  it('does not treat session tokens as legacy', () => {
    expect(legacyAccessStillValid({ sid: 'abc' }, now, until)).toBe(false);
    expect(legacyAccessStillValid({ exp: now }, now, until)).toBe(false);
  });
});

describe('access token expiry', () => {
  const secret = 'test-secret-test-secret-test-secret-32';

  it('always sets exp on a new access token', () => {
    const token = signAccessToken(
      { userId: 'u', userRole: 'USER', sid: 's', typ: 'access' },
      secret,
      '15m',
      (payload, secret, options) => jwt.sign(payload, secret, options),
      jwt.decode,
    );
    const decoded = jwt.decode(token) as { exp?: number };
    expect(decoded.exp).toBeGreaterThan(Math.floor(Date.now() / 1000));
  });

  it('rejects malformed and already expired tokens', () => {
    expect(() => jwt.verify('not-a-token', secret)).toThrow();
    expect(() =>
      jwt.verify(
        jwt.sign({ userId: 'u', userRole: 'USER' }, secret, { expiresIn: '-1s' }),
        secret,
      ),
    ).toThrow();
  });
});
