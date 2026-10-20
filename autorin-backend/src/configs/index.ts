import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { AuthGuardsModule } from 'src/auth/auth-guards.module';
import { MeilisearchModule } from 'src/services/meilisearch';
import { RedisCacheModule } from 'src/services/redis-cache/redis-cache.module';
import { MongodbConfig } from './mongodb';
import { GraphqlConfig } from './graphql';
import { MinioModule } from 'src/utils/minio';
import { validateEnv } from './env';
import { SecurityModule } from './security';
import { SessionModule } from 'src/modules/auth/session/session.module';

const nodeEnv = process.env.NODE_ENV || 'development';
const envFilePath = [`.env.${nodeEnv}`, '.env'];

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath,
      validate: validateEnv,
    }),
    ScheduleModule.forRoot(),
    SecurityModule,
    MeilisearchModule,
    RedisCacheModule,
    MongodbConfig,
    SessionModule,
    AuthGuardsModule,
    GraphqlConfig,
    MinioModule,
  ],
})
export class Configs {}
