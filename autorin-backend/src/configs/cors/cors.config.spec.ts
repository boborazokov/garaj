import { ConfigService } from '@nestjs/config';
import { buildCorsOptions } from './cors.config';

function mockConfig(env: Record<string, string | undefined>): ConfigService {
  return {
    get: (key: string) => env[key],
  } as unknown as ConfigService;
}

function checkOrigin(
  options: ReturnType<typeof buildCorsOptions>,
  origin: string | undefined,
): Promise<{ allowed: boolean; error?: Error }> {
  return new Promise((resolve) => {
    const originFn = options.origin;
    if (typeof originFn !== 'function') {
      resolve({ allowed: false, error: new Error('origin is not a function') });
      return;
    }
    originFn(origin as string, (err, allowed) => {
      resolve({
        allowed: Boolean(allowed) && !err,
        error: err ?? undefined,
      });
    });
  });
}

describe('buildCorsOptions', () => {
  it('allows listed production origins and rejects unknown', async () => {
    const options = buildCorsOptions(
      mockConfig({
        NODE_ENV: 'production',
        ALLOWED_ORIGINS:
          'https://autorin-web-alpha.vercel.app,https://autorin-backend.onrender.com',
      }),
    );

    expect(
      (
        await checkOrigin(
          options,
          'https://autorin-web-alpha.vercel.app',
        )
      ).allowed,
    ).toBe(true);
    expect(
      (await checkOrigin(options, 'https://evil.example.com')).allowed,
    ).toBe(false);
  });

  it('rejects localhost and 127.0.0.1 in production even if listed', async () => {
    const options = buildCorsOptions(
      mockConfig({
        NODE_ENV: 'production',
        ALLOWED_ORIGINS:
          'https://autorin-web-alpha.vercel.app,http://localhost:5173,http://127.0.0.1:3000',
      }),
    );

    expect((await checkOrigin(options, 'http://localhost:5173')).allowed).toBe(
      false,
    );
    expect(
      (await checkOrigin(options, 'http://127.0.0.1:3000')).allowed,
    ).toBe(false);
    expect(
      (
        await checkOrigin(
          options,
          'https://autorin-web-alpha.vercel.app',
        )
      ).allowed,
    ).toBe(true);
  });

  it('allows localhost in development when listed', async () => {
    const options = buildCorsOptions(
      mockConfig({
        NODE_ENV: 'development',
        ALLOWED_ORIGINS: 'http://localhost:5173',
      }),
    );

    expect((await checkOrigin(options, 'http://localhost:5173')).allowed).toBe(
      true,
    );
  });

  it('allows requests with no Origin (native / same-origin)', async () => {
    const options = buildCorsOptions(
      mockConfig({
        NODE_ENV: 'production',
        ALLOWED_ORIGINS: 'https://autorin-web-alpha.vercel.app',
      }),
    );

    expect((await checkOrigin(options, undefined)).allowed).toBe(true);
  });

  it('throws in production when ALLOWED_ORIGINS is empty', () => {
    expect(() =>
      buildCorsOptions(mockConfig({ NODE_ENV: 'production' })),
    ).toThrow(/ALLOWED_ORIGINS/);
  });

  it('keeps credentials enabled', () => {
    const options = buildCorsOptions(
      mockConfig({
        NODE_ENV: 'production',
        ALLOWED_ORIGINS: 'https://autorin-web-alpha.vercel.app',
      }),
    );
    expect(options.credentials).toBe(true);
  });
});
