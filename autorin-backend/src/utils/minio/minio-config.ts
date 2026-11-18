import { ConfigService } from '@nestjs/config';
import { isProductionEnv } from 'src/configs/env';

export type MinioClientConfig = {
  endPoint: string;
  port: number;
  useSSL: boolean;
  accessKey: string;
  secretKey: string;
  region: string;
};

function isLoopbackHost(host: string): boolean {
  const normalized = host.trim().toLowerCase();
  return (
    normalized === 'localhost' ||
    normalized === '127.0.0.1' ||
    normalized === '::1' ||
    normalized === '0.0.0.0'
  );
}

/**
 * Resolve MinIO / S3-compatible client settings.
 * Production refuses missing credentials and loopback endpoints.
 * Development may default endpoint/port for local docker-compose MinIO.
 */
export function resolveMinioClientConfig(
  configService: ConfigService,
): MinioClientConfig {
  const nodeEnv = configService.get<string>('NODE_ENV');
  const production = isProductionEnv(nodeEnv);

  const endPointRaw = configService.get<string>('MINIO_ENDPOINT')?.trim();
  const accessKey = configService.get<string>('MINIO_ACCESS_KEY')?.trim();
  const secretKey = configService.get<string>('MINIO_SECRET_KEY')?.trim();
  const region =
    configService.get<string>('MINIO_REGION')?.trim() || 'us-east-1';
  const useSSL = configService.get<string>('MINIO_USE_SSL') === 'true';
  const portRaw = configService.get<string>('MINIO_PORT');
  const port = parseInt(portRaw ?? (production ? '' : '9000'), 10);

  if (production) {
    if (!endPointRaw) {
      throw new Error(
        'MINIO_ENDPOINT must be set in production (object storage host, not localhost)',
      );
    }
    if (isLoopbackHost(endPointRaw)) {
      throw new Error(
        'MINIO_ENDPOINT must not be localhost/loopback in production',
      );
    }
    if (!accessKey || !secretKey) {
      throw new Error(
        'MINIO_ACCESS_KEY and MINIO_SECRET_KEY must be set in production (use dashboard secrets)',
      );
    }
    if (!Number.isFinite(port) || port <= 0) {
      throw new Error('MINIO_PORT must be a positive integer in production');
    }
  }

  const endPoint = endPointRaw || 'localhost';
  if (!accessKey || !secretKey) {
    throw new Error(
      'MINIO_ACCESS_KEY and MINIO_SECRET_KEY are required (see .env.example for local MinIO)',
    );
  }

  return {
    endPoint,
    port: Number.isFinite(port) && port > 0 ? port : 9000,
    useSSL,
    accessKey,
    secretKey,
    region,
  };
}
