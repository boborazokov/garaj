import { plainToInstance } from 'class-transformer';
import {
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
  validateSync,
} from 'class-validator';

export class EnvironmentVariables {
  @IsIn(['development', 'production', 'test'])
  NODE_ENV: string = 'development';

  @IsString()
  @IsNotEmpty()
  @MinLength(32, {
    message: 'JWT_SECRET must be at least 32 characters in all environments',
  })
  JWT_SECRET: string;

  @IsString()
  @IsNotEmpty()
  DATABASE_URL: string;

  @IsOptional()
  @IsString()
  PORT?: string;

  /** Comma-separated browser origins, e.g. https://app.example.com,http://localhost:3000 */
  @IsOptional()
  @IsString()
  ALLOWED_ORIGINS?: string;

  @IsOptional()
  @IsString()
  JSON_BODY_LIMIT?: string;

  @IsOptional()
  @IsString()
  GRAPHQL_MAX_DEPTH?: string;

  @IsOptional()
  @IsString()
  GRAPHQL_MAX_COMPLEXITY?: string;

  @IsOptional()
  @IsString()
  GRAPHQL_MAX_QUERY_BYTES?: string;

  @IsOptional()
  @IsString()
  THROTTLE_TTL_MS?: string;

  @IsOptional()
  @IsString()
  THROTTLE_LIMIT?: string;

  @IsOptional()
  @IsString()
  UPLOAD_MAX_FILE_BYTES?: string;

  @IsOptional()
  @IsString()
  SWAGGER_ENABLED?: string;

  @IsOptional()
  @IsString()
  SWAGGER_USER?: string;

  @IsOptional()
  @IsString()
  SWAGGER_PASSWORD?: string;

  @IsOptional()
  @IsString()
  WS_MAX_CONNECTIONS_PER_USER?: string;

  @IsOptional()
  @IsString()
  WS_HANDSHAKE_MIN_INTERVAL_MS?: string;

  @IsOptional()
  @IsString()
  ACCESS_TOKEN_TTL?: string;

  @IsOptional()
  @IsString()
  REFRESH_TOKEN_TTL_MS?: string;

  @IsOptional()
  @IsString()
  LEGACY_ACCESS_TOKEN_UNTIL?: string;

  @IsOptional()
  @IsIn(['log', 'http'])
  SMS_PROVIDER?: string;

  @IsOptional()
  @IsString()
  SMS_HTTP_URL?: string;

  @IsOptional()
  @IsString()
  SMS_HTTP_TOKEN?: string;
}

export function validateEnv(config: Record<string, unknown>) {
  const validated = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validated, {
    skipMissingProperties: false,
    whitelist: true,
  });

  if (errors.length > 0) {
    const message = errors
      .map((e) => Object.values(e.constraints ?? {}).join(', '))
      .join('; ');
    throw new Error(`Environment validation failed: ${message}`);
  }

  // Merge so validated keys stay typed while MINIO_*, BOT_*, etc. remain available.
  return { ...config, ...validated };
}

export function isProductionEnv(nodeEnv?: string): boolean {
  return (nodeEnv ?? process.env.NODE_ENV ?? 'development') === 'production';
}

export function parseAllowedOrigins(raw?: string): string[] {
  if (!raw?.trim()) {
    return [];
  }
  return raw
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
}
