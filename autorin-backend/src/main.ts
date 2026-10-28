import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import {
  INestApplication,
  Logger,
  ValidationPipe,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MinioService } from './utils/minio';
import { CategoryService } from './modules/category/service';
import { UserService } from './modules/user/service';
import { AppSettingsService } from './modules/app-settings/service/app-settings.service';
import { ROUTES } from './constants';
import { json } from 'express';
import { graphqlUploadExpress } from 'graphql-upload-ts';
import { HttpExceptionFilter } from './common/filters';
import { buildCorsOptions } from './configs/cors/cors.config';
import { setupSwagger } from './configs/bootstrap';
import { createMaxQuerySizeMiddleware } from './configs/graphql/graphql-security.validation';

export let app: INestApplication = null as unknown as INestApplication;

async function bootstrap() {
  const nestApp = await NestFactory.create(AppModule, {
    logger:
      process.env.NODE_ENV === 'production'
        ? ['error', 'warn', 'log']
        : ['error', 'warn', 'log', 'debug', 'verbose'],
  });

  const config = nestApp.get(ConfigService);
  const jsonLimit = config.get<string>('JSON_BODY_LIMIT') ?? '5mb';

  nestApp.enableCors(buildCorsOptions(config));

  const maxUploadBytes = Number(
    config.get('UPLOAD_MAX_FILE_BYTES') ?? 10_485_760,
  );
  // Parses GraphQL multipart uploads (updateProfile image, createPart, etc.)
  nestApp.use(
    ROUTES.API,
    graphqlUploadExpress({
      maxFileSize: maxUploadBytes,
      maxFiles: 10,
    }),
  );

  nestApp.use(json({ limit: jsonLimit }));
  nestApp.use(ROUTES.API, createMaxQuerySizeMiddleware(config));

  // NB: do NOT enable `whitelist: true` globally — it silently drops
  // GraphQL @Field() properties that have no class-validator decorator
  // (e.g. raw JWT/ID strings), breaking confirmSignUp and similar flows.
  // GraphQL schema already rejects unknown fields at validation stage.
  nestApp.useGlobalPipes(
    new ValidationPipe({
      transform: true,
    }),
  );

  nestApp.useGlobalFilters(new HttpExceptionFilter(config));

  app = nestApp;

  setupSwagger(nestApp);

  const minioService = nestApp.get(MinioService);
  await minioService.initializeBuckets();

  const userService = nestApp.get(UserService);
  const staffSeeded = await userService.seedDefaultStaffAccounts();
  Logger.log(`Default staff accounts upserted: ${staffSeeded}`, 'Bootstrap');

  const categoryService = nestApp.get(CategoryService);
  const seeded = await categoryService.seedPartCategories();
  if (seeded > 0) {
    Logger.log(`PART categories seeded/updated: ${seeded}`, 'Bootstrap');
  }

  const vehicleSeeded = await categoryService.seedVehicleCatalog();
  Logger.log(`Vehicle catalog brands/models upserted: ${vehicleSeeded}`, 'Bootstrap');

  const appSettings = nestApp.get(AppSettingsService);
  const moderationOn = await appSettings.isProductModerationEnabled();
  Logger.log(
    `Product moderation ${moderationOn ? 'enabled' : 'disabled'}`,
    'Bootstrap',
  );
  if (
    config.get<string>('NODE_ENV') === 'production' &&
    (config.get<string>('SMS_PROVIDER') !== 'http' ||
      !config.get<string>('SMS_HTTP_URL'))
  ) {
    Logger.error(
      'Production SMS is not configured. Registration and password reset will fail until SMS_PROVIDER=http and SMS_HTTP_URL are set.',
      'Bootstrap',
    );
  }

  const port = config.get<number>('PORT') ?? 7007;

  // Quiet probe noise from browsers / ngrok (`GET /`, `GET /json/version`).
  const http = nestApp.getHttpAdapter().getInstance();
  http.get('/', (_req, res) => {
    res.status(200).json({
      ok: true,
      service: 'autorin-backend',
      graphql: '/api',
    });
  });
  http.get('/json/version', (_req, res) => {
    res.status(200).json({ version: 'dev' });
  });
  http.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  await nestApp.listen(port, '0.0.0.0');
  Logger.log(`Application listening on http://0.0.0.0:${port}`, 'Bootstrap');
}

void bootstrap();
