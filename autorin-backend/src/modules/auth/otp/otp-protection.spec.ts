import {
  MemoryOtpCounterStore,
  OTP_MAX_ATTEMPTS,
  OtpCounterStore,
  OtpProtection,
  OtpStoreUnavailableError,
} from './otp-protection';

describe('OtpProtection', () => {
  it('shares the five-attempt lock across two instances', async () => {
    const store = new MemoryOtpCounterStore();
    const a = new OtpProtection(store);
    const b = new OtpProtection(store);
    const token = 'same-token';

    for (let i = 0; i < OTP_MAX_ATTEMPTS; i++) {
      expect(await a.assertAllowed(token)).toBe(true);
      await b.recordFailure(token);
    }
    expect(await a.assertAllowed(token)).toBe(false);
    expect(await b.assertAllowed(token)).toBe(false);
  });

  it('rejects a consumed code', async () => {
    const guard = new OtpProtection(new MemoryOtpCounterStore());
    expect(await guard.consume('otp-token')).toBe(true);
    expect(await guard.consume('otp-token')).toBe(false);
  });

  it('fails closed when the store throws', async () => {
    const broken: OtpCounterStore = {
      get: async () => {
        throw new Error('redis down');
      },
      increment: async () => {
        throw new Error('redis down');
      },
      consumeOnce: async () => {
        throw new Error('redis down');
      },
    };
    const guard = new OtpProtection(broken);
    await expect(guard.assertAllowed('t')).rejects.toBeInstanceOf(
      OtpStoreUnavailableError,
    );
  });
});
