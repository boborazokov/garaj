import { OtpAttemptGuard } from './otp-attempt.guard';

describe('OtpAttemptGuard', () => {
  it('locks a token after five failures', () => {
    const guard = new OtpAttemptGuard();
    const token = 'reset-token';
    for (let i = 0; i < 5; i++) {
      expect(guard.assertAllowed(token)).toBe(true);
      guard.recordFailure(token);
    }
    expect(guard.assertAllowed(token)).toBe(false);
  });

  it('forgets failures after a successful clear', () => {
    const guard = new OtpAttemptGuard();
    guard.recordFailure('t');
    guard.clear('t');
    expect(guard.assertAllowed('t')).toBe(true);
  });
});
