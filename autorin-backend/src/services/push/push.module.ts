import { BullModule } from '@nestjs/bullmq';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { DeviceTokenModule } from 'src/modules/device-token/module';
import { UserNotificationModule } from 'src/modules/user-notification/module/user-notification.module';
import { FirebaseDebugController } from './firebase-debug.controller';
import { FirebaseService } from './firebase.service';
import { PushService, PUSH_QUEUE } from './push.service';
import { PushWorker } from './push.worker';

/**
 * Push subsystem wiring.
 *
 *  - `BullModule.forRootAsync` configures the Redis connection used by
 *    the BullMQ queue. We deliberately keep it on a SEPARATE DB index
 *    from the PubSub instance (0 vs 1) so flushing one for ops doesn't
 *    nuke the other.
 *  - `BullModule.registerQueue` declares the named "push" queue used
 *    by both producer (`PushService`) and consumer (`PushWorker`).
 *  - The module is intentionally NOT global. Features that need to
 *    send push (e.g. Message, Order) import it explicitly. This keeps
 *    the dependency graph honest.
 */
@Module({
  imports: [
    BullModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        connection: {
          host: config.get<string>('REDIS_HOST') || '127.0.0.1',
          port: Number(config.get<string>('REDIS_PORT') || 6379),
          password: config.get<string>('REDIS_PASSWORD') || undefined,
          db: Number(config.get<string>('REDIS_QUEUE_DB') || 1),
          maxRetriesPerRequest: null,
          enableReadyCheck: true,
        },
      }),
    }),
    BullModule.registerQueue({ name: PUSH_QUEUE }),
    DeviceTokenModule,
    UserNotificationModule,
  ],
  providers: [FirebaseService, PushService, PushWorker],
  controllers: [FirebaseDebugController],
  exports: [PushService, FirebaseService],
})
export class PushModule {}
