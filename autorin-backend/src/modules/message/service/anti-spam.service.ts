import {
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { Types } from 'mongoose';

/**
 * Sliding-window rate limit for chat traffic.
 *
 * Stage 1 stub: protects against the obvious abuse (single user
 * flooding a thread) by capping `sendMessage` to N events per W
 * seconds. Backed by Redis so it works across all API replicas.
 *
 * Future hooks (anti-spam Stage 2):
 *  - Per-recipient rate limit (prevents broadcast spam to N sellers).
 *  - Content moderation hook (call out to a moderation service before
 *    persisting).
 *  - Shadow-ban list (`spam:bannedUsers`).
 */
@Injectable()
export class AntiSpamService implements OnModuleInit {
  private readonly logger = new Logger(AntiSpamService.name);
  private redis!: Redis;

  // 8 messages per 10 seconds — tuned for human conversation.
  private static readonly LIMIT = 8;
  private static readonly WINDOW_SECONDS = 10;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    this.redis = new Redis({
      host: this.config.get<string>('REDIS_HOST') || '127.0.0.1',
      port: Number(this.config.get<string>('REDIS_PORT') || 6379),
      password: this.config.get<string>('REDIS_PASSWORD') || undefined,
      db: Number(this.config.get<string>('REDIS_RATELIMIT_DB') || 2),
      maxRetriesPerRequest: 1,
      lazyConnect: true,
    });
    this.redis.on('error', () => {
      // Handled in connect/assertNotFlooding; avoids ioredis unhandled error events.
    });
    void this.redis.connect().catch((e) => {
      this.logger.warn(
        `Redis connect failed for anti-spam: ${(e as Error).message}. Rate limiting will be disabled.`,
      );
    });
  }

  /**
   * Throws HTTP 429 when the user exceeds the limit.
   * Falls back to a no-op (logged) if Redis is unreachable so the
   * core feature stays usable during infra hiccups.
   */
  async assertNotFlooding(
    userId: Types.ObjectId,
    action: 'sendMessage',
  ): Promise<void> {
    if (!this.redis || this.redis.status !== 'ready') return;

    const key = `rl:${action}:${userId.toString()}`;
    try {
      const count = await this.redis.incr(key);
      if (count === 1) {
        await this.redis.expire(key, AntiSpamService.WINDOW_SECONDS);
      }
      if (count > AntiSpamService.LIMIT) {
        throw new HttpException(
          `Too many ${action}s. Please slow down.`,
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    } catch (e) {
      if (e instanceof HttpException) throw e;
      this.logger.warn(`Anti-spam Redis op failed: ${(e as Error).message}`);
      // Degrade gracefully on infra issues — never block legit chat.
    }
  }
}
