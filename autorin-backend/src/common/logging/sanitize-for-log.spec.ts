import { sanitizeForLog, sanitizeForLogObject } from './sanitize-for-log';

describe('sanitizeForLog', () => {
  it('redacts sensitive keys case-insensitively', () => {
    const result = sanitizeForLogObject({
      OTP: '12345',
      Code: '99999',
      Password: 'secret',
      Authorization: 'Bearer abc',
      accessToken: 'a',
      refresh_token: 'b',
      token: 'c',
      secret: 'd',
      cookie: 'e',
      'Set-Cookie': 'f',
      apiKey: 'g',
      api_key: 'h',
      phone: '+998901234567',
    });

    expect(result.OTP).toBe('[redacted]');
    expect(result.Code).toBe('[redacted]');
    expect(result.Password).toBe('[redacted]');
    expect(result.Authorization).toBe('[redacted]');
    expect(result.accessToken).toBe('[redacted]');
    expect(result.refresh_token).toBe('[redacted]');
    expect(result.token).toBe('[redacted]');
    expect(result.secret).toBe('[redacted]');
    expect(result.cookie).toBe('[redacted]');
    expect(result['Set-Cookie']).toBe('[redacted]');
    expect(result.apiKey).toBe('[redacted]');
    expect(result.api_key).toBe('[redacted]');
    expect(result.phone).toBe('+998901234567');
  });

  it('redacts nested objects', () => {
    const result = sanitizeForLog({
      user: { id: '1', password: 'x', profile: { otp: '11111' } },
    }) as Record<string, unknown>;

    const user = result.user as Record<string, unknown>;
    expect(user.password).toBe('[redacted]');
    expect((user.profile as Record<string, unknown>).otp).toBe('[redacted]');
    expect(user.id).toBe('1');
  });

  it('redacts sensitive keys inside arrays', () => {
    const result = sanitizeForLog([
      { token: 'abc', name: 'a' },
      { code: '12345', ok: true },
    ]) as Array<Record<string, unknown>>;

    expect(result[0].token).toBe('[redacted]');
    expect(result[0].name).toBe('a');
    expect(result[1].code).toBe('[redacted]');
    expect(result[1].ok).toBe(true);
  });

  it('leaves primitives unchanged', () => {
    expect(sanitizeForLog('hello')).toBe('hello');
    expect(sanitizeForLog(42)).toBe(42);
    expect(sanitizeForLog(null)).toBe(null);
  });
});
