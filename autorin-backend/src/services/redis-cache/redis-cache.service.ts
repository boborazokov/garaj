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
