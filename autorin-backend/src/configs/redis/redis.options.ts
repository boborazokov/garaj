import { ConfigService } from '@nestjs/config';
import type { RedisOptions } from 'ioredis';

/**
 * Shared ioredis options for Upstash / Redis Cloud (TLS) and local Redis.
 * Set REDIS_TLS=true for managed providers that require rediss://.
 */
export function buildRedisOptions(
  config: ConfigService,
  overrides: RedisOptions = {},
): RedisOptions {
  const useTls =
    (config.get<string>('REDIS_TLS') ?? '').toLowerCase() === 'true';

  return {
    host: config.get<string>('REDIS_HOST') || '127.0.0.1',
    port: Number(config.get<string>('REDIS_PORT') || 6379),
    password: config.get<string>('REDIS_PASSWORD') || undefined,
    ...(useTls ? { tls: {} } : {}),
    ...overrides,
  };
}
