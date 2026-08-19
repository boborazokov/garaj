import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRedis } from '@nestjs-modules/ioredis';
import Redis from 'ioredis';

/**
 * Redis keys (TTL in seconds):
 * - otp:ip:{ip}           — 10 attempts / 3600s
 * - otp:phone:{phone}     — 5 attempts / 3600s
 * - otp:resend:{phone}    — 1 resend / 60s cooldown
 * - otp:lock:{phone}      — 15 min lock after 5 failed confirms
 */
@Injectable()
export class OtpRateLimitService {
  constructor(@InjectRedis() private readonly redis: Redis) {}

  async assertCanRequestOtp(phone: string, ip: string) {
    await this.assertNotLocked(phone);
    const ipKey = `otp:ip:${ip}`;
    const phoneKey = `otp:phone:${phone}`;
    const ipCount = await this.incrWithTtl(ipKey, 3600);
    const phoneCount = await this.incrWithTtl(phoneKey, 3600);
    if (ipCount > 10 || phoneCount > 5) {
      throw new HttpException(
        { message: 'Too many requests', code: 'RATE_LIMITED' },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }

  async assertCanResend(phone: string) {
    const key = `otp:resend:${phone}`;
    const exists = await this.redis.set(key, '1', 'EX', 60, 'NX');
    if (exists == null) {
      throw new HttpException(
        { message: 'Resend cooldown', code: 'RESEND_COOLDOWN' },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }

  async recordFailedConfirm(phone: string) {
    const key = `otp:fail:${phone}`;
    const fails = await this.incrWithTtl(key, 900);
    if (fails >= 5) {
      await this.redis.setex(`otp:lock:${phone}`, 900, '1');
    }
  }

  async assertNotLocked(phone: string) {
    if (await this.redis.exists(`otp:lock:${phone}`)) {
      throw new HttpException(
        { message: 'Temporarily locked', code: 'OTP_LOCKED' },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }

  /** Generic auth response — do not reveal if user exists. */
  static genericAuthMessage() {
    return 'If the number is registered, you will receive a code shortly.';
  }

  private async incrWithTtl(key: string, ttlSec: number): Promise<number> {
    const n = await this.redis.incr(key);
    if (n === 1) await this.redis.expire(key, ttlSec);
    return n;
  }
}
