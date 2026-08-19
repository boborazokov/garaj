import { Logger, Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RedisPubSub } from 'graphql-redis-subscriptions';
import Redis, { RedisOptions } from 'ioredis';

/**
 * DI token for the GraphQL PubSub instance.
 *
 * We intentionally export it as a string so consumers can `@Inject(PUBSUB)`
 * without importing the underlying Redis package, which keeps the
 * dependency surface narrow.
 */
export const PUBSUB = 'PUB_SUB';

/**
 * Redis-backed PubSub provider.
 *
 * Why Redis (and not the in-memory PubSub):
 * - When the API is horizontally scaled (pm2 cluster / k8s replicas),
 *   subscribers and publishers end up in different node processes.
 *   In-memory PubSub silently breaks in that scenario; Redis fixes it
 *   without changing resolver code.
 *
 * Connection strategy:
 * - We keep TWO separate Redis connections (publisher / subscriber) as
 *   recommended by `graphql-redis-subscriptions`. Sharing a single
 *   connection causes the subscriber to be unable to issue commands
 *   while in subscribe mode.
 * - `retryStrategy` keeps reconnects bounded and idempotent.
 * - `maxRetriesPerRequest: null` is required for BullMQ-compatible
 *   connections; we keep the same here for consistency.
 */
export const pubSubProvider: Provider = {
  provide: PUBSUB,
  inject: [ConfigService],
  useFactory: (config: ConfigService): RedisPubSub => {
    const logger = new Logger('PubSub');

    const options: RedisOptions = {
      host: config.get<string>('REDIS_HOST') || '127.0.0.1',
      port: Number(config.get<string>('REDIS_PORT') || 6379),
      password: config.get<string>('REDIS_PASSWORD') || undefined,
      db: Number(config.get<string>('REDIS_PUBSUB_DB') || 0),
      maxRetriesPerRequest: null,
      enableReadyCheck: true,
      retryStrategy: (attempts) => Math.min(attempts * 200, 2000),
      reconnectOnError: (err) => {
        // Reconnect when Redis returns READONLY (e.g. after failover).
        if (err?.message?.includes('READONLY')) return true;
        return false;
      },
    };

    const publisher = new Redis(options);
    const subscriber = new Redis(options);

    publisher.on('error', (err) =>
      logger.error(`Publisher error: ${err.message}`),
    );
    subscriber.on('error', (err) =>
      logger.error(`Subscriber error: ${err.message}`),
    );
    publisher.on('connect', () => logger.log('Publisher connected'));
    subscriber.on('connect', () => logger.log('Subscriber connected'));

    return new RedisPubSub({ publisher, subscriber });
  },
};
