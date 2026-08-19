import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { pubSubProvider, PUBSUB } from './pubsub.provider';

/**
 * PubSubModule is marked `@Global` so the single Redis-backed PubSub
 * instance is reachable from any feature module (conversation, message,
 * presence, notification) without having to re-import it everywhere.
 */
@Global()
@Module({
  imports: [ConfigModule],
  providers: [pubSubProvider],
  exports: [PUBSUB],
})
export class PubSubModule {}
