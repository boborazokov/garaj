import { Client } from 'minio';
import { ConfigService } from '@nestjs/config';
import { FactoryProvider } from '@nestjs/common';
import { resolveMinioClientConfig } from './minio-config';

export const MINIO_CLIENT_TOKEN = 'MINIO_CLIENT';

export const MINIO_CLIENT_PROVIDER: FactoryProvider = {
  inject: [ConfigService],
  provide: MINIO_CLIENT_TOKEN,
  useFactory: (configService: ConfigService) => {
    const cfg = resolveMinioClientConfig(configService);

    return new Client({
      port: cfg.port,
      region: cfg.region,
      useSSL: cfg.useSSL,
      endPoint: cfg.endPoint,
      accessKey: cfg.accessKey,
      secretKey: cfg.secretKey,
    });
  },
};
