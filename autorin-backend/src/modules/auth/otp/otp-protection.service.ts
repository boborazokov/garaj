import { Injectable } from '@nestjs/common';
import { RedisCacheService } from 'src/services/redis-cache/redis-cache.service';
import { OtpCounterStore, OtpProtection } from './otp-protection';

class RedisOtpCounterStore implements OtpCounterStore {
  constructor(private readonly redis: RedisCacheService) {}

  get(key: string) {
    return this.redis.getCount(key);
  }

  increment(key: string, ttlMs: number) {
    return this.redis.incrementExpiring(key, ttlMs);
  }

  consumeOnce(key: string, ttlMs: number) {
    return this.redis.consumeOnce(key, ttlMs);
  }
}

@Injectable()
export class OtpProtectionService extends OtpProtection {
  constructor(redis: RedisCacheService) {
    super(new RedisOtpCounterStore(redis));
  }
}
