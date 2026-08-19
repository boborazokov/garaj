import { CorsOptions } from '@nestjs/common/interfaces/external/cors-options.interface';
import { ConfigService } from '@nestjs/config';
import { isProductionEnv, parseAllowedOrigins } from '../env';

/**
 * Production: only origins listed in ALLOWED_ORIGINS (reject unknown).
 * Development: reflects the request origin when ALLOWED_ORIGINS is unset
 * (convenient for Flutter web / local tools); set ALLOWED_ORIGINS to test prod-like CORS locally.
 */
export function buildCorsOptions(config: ConfigService): CorsOptions {
  const isProd = isProductionEnv(config.get<string>('NODE_ENV'));
  const allowed = parseAllowedOrigins(config.get<string>('ALLOWED_ORIGINS'));

  if (isProd && allowed.length === 0) {
    throw new Error(
      'ALLOWED_ORIGINS must be set in production (comma-separated list of HTTPS origins)',
    );
  }

  return {
    origin: (origin, callback) => {
      if (!origin) {
        callback(null, true);
        return;
      }

      if (!isProd && allowed.length === 0) {
        callback(null, true);
        return;
      }

      if (allowed.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error('Not allowed by CORS'), false);
    },
    credentials: true,
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Apollo-Require-Preflight',
      'X-Apollo-Operation-Name',
    ],
    exposedHeaders: ['Content-Length', 'Content-Type'],
    maxAge: 86400,
  };
}
