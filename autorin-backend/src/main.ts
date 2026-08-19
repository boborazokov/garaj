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

  const categoryService = nestApp.get(CategoryService);
  const seeded = await categoryService.seedPartCategories();
  if (seeded > 0) {
    Logger.log(`PART categories seeded/updated: ${seeded}`, 'Bootstrap');
  }

  const port = config.get<number>('PORT') ?? 7007;
  await nestApp.listen(port);
  Logger.log(`Application listening on port ${port}`, 'Bootstrap');
}

bootstrap().then(async () => {
  const { startBot } = await import('./bot/index');
  await startBot();
});
