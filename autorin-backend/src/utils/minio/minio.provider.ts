import { Client } from 'minio';
import { ConfigService } from '@nestjs/config';
import { FactoryProvider } from '@nestjs/common';

export const MINIO_CLIENT_TOKEN = 'MINIO_CLIENT';

export const MINIO_CLIENT_PROVIDER: FactoryProvider = {
  inject: [ConfigService],
  provide: MINIO_CLIENT_TOKEN,
  useFactory: (configService: ConfigService) => {
    const MINIO_ENDPOINT =
      configService.get<string>('MINIO_ENDPOINT') ?? 'localhost';
    const MINIO_PORT = parseInt(
      configService.get<string>('MINIO_PORT') ?? '9000',
    );
    const MINIO_USE_SSL = configService.get<string>('MINIO_USE_SSL') === 'true';
    const MINIO_ACCESS_KEY = configService.get<string>('MINIO_ACCESS_KEY')!;
    const MINIO_SECRET_KEY = configService.get<string>('MINIO_SECRET_KEY')!;
    const MINIO_REGION =
      configService.get<string>('MINIO_REGION') || 'us-east-1';

    const minioClient = new Client({
      port: MINIO_PORT,
      region: MINIO_REGION,
      useSSL: MINIO_USE_SSL,
      endPoint: MINIO_ENDPOINT,
      accessKey: MINIO_ACCESS_KEY,
      secretKey: MINIO_SECRET_KEY,
    });

    return minioClient;
  },
};
