import { ConfigService } from '@nestjs/config';
import { resolveMinioClientConfig } from './minio-config';

function mockConfig(env: Record<string, string | undefined>): ConfigService {
  return {
    get: (key: string) => env[key],
  } as unknown as ConfigService;
}

describe('resolveMinioClientConfig', () => {
  it('allows localhost defaults in development when credentials are set', () => {
    const cfg = resolveMinioClientConfig(
      mockConfig({
        NODE_ENV: 'development',
        MINIO_ACCESS_KEY: 'minioadmin',
        MINIO_SECRET_KEY: 'minioadmin',
      }),
    );
    expect(cfg.endPoint).toBe('localhost');
    expect(cfg.port).toBe(9000);
  });

  it('rejects missing production credentials', () => {
    expect(() =>
      resolveMinioClientConfig(
        mockConfig({
          NODE_ENV: 'production',
          MINIO_ENDPOINT: 'storage.example.com',
          MINIO_PORT: '443',
          MINIO_USE_SSL: 'true',
        }),
      ),
    ).toThrow(/MINIO_ACCESS_KEY and MINIO_SECRET_KEY/);
  });

  it('rejects localhost endpoint in production', () => {
    expect(() =>
      resolveMinioClientConfig(
        mockConfig({
          NODE_ENV: 'production',
          MINIO_ENDPOINT: 'localhost',
          MINIO_PORT: '9000',
          MINIO_ACCESS_KEY: 'ak',
          MINIO_SECRET_KEY: 'sk',
        }),
      ),
    ).toThrow(/must not be localhost/);
  });

  it('accepts explicit production storage host', () => {
    const cfg = resolveMinioClientConfig(
      mockConfig({
        NODE_ENV: 'production',
        MINIO_ENDPOINT: 's3.example.com',
        MINIO_PORT: '443',
        MINIO_USE_SSL: 'true',
        MINIO_ACCESS_KEY: 'ak',
        MINIO_SECRET_KEY: 'sk',
        MINIO_REGION: 'eu-central-1',
      }),
    );
    expect(cfg.endPoint).toBe('s3.example.com');
    expect(cfg.useSSL).toBe(true);
    expect(cfg.region).toBe('eu-central-1');
  });
});
