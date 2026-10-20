import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisCacheService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisCacheService.name);
  private readonly redis: Redis;

  constructor(config: ConfigService) {
    this.redis = new Redis({
      host: config.get<string>('REDIS_HOST') ?? 'localhost',
      port: config.get<number>('REDIS_PORT') ?? 6379,
      db: config.get<number>('REDIS_CACHE_DB') ?? 3,
      maxRetriesPerRequest: 3,
      lazyConnect: true,
    });

    this.redis.connect().catch((err) => {
      this.logger.warn(`Redis cache connect failed: ${err.message}`);
    });
  }

  async onModuleDestroy() {
    await this.redis.quit().catch(() => undefined);
  }

  async getJson<T>(key: string): Promise<T | null> {
    const raw = await this.redis.get(key);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as T;
    } catch {
      return null;
    }
  }

  async setJson(key: string, value: unknown, ttlSeconds: number) {
    await this.redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
  }

  async del(key: string) {
    await this.redis.del(key);
  }

  private async ready() {
    if (this.redis.status === 'wait' || this.redis.status === 'end') {
      await this.redis.connect();
    }
    if (this.redis.status !== 'ready') {
      throw new Error('Redis is not ready');
    }
  }

  async getCount(key: string): Promise<number> {
    await this.ready();
    const raw = await this.redis.get(key);
    const count = raw ? Number(raw) : 0;
    return Number.isFinite(count) ? count : 0;
  }

  /** INCR plus TTL on the first increment. Shared across API processes. */
  async incrementExpiring(key: string, ttlMs: number): Promise<number> {
    await this.ready();
    const count = await this.redis.incr(key);
    if (count === 1) {
      await this.redis.pexpire(key, ttlMs);
    }
    return count;
  }

  /** SET key NX PX. True when this caller won the consume. */
  async consumeOnce(key: string, ttlMs: number): Promise<boolean> {
    await this.ready();
    const result = await this.redis.set(key, '1', 'PX', ttlMs, 'NX');
    return result === 'OK';
  }

  keys = {
    recommend: (userId: string) => `recommend:${userId}`,
    trendingGlobal: () => 'trending:global',
    trendingCity: (city: string) => `trending:city:${city}`,
    similar: (partId: string) => `similar:${partId}`,
    recentlyViewed: (userId: string) => `recent:${userId}`,
    mapWorkshops: (boundsHash: string) => `map:bounds:${boundsHash}`,
    mapTrendingCity: (city: string) => `map:trending:city:${city}`,
  };
}
