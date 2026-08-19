import {
  INestApplication,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { NextFunction, Request, Response } from 'express';
import { ROUTES } from 'src/constants';
import { isProductionEnv } from '../env';

/**
 * Swagger is disabled in production unless SWAGGER_ENABLED=true.
 * When enabled in production, optional HTTP Basic auth protects /docs.
 */
export function setupSwagger(app: INestApplication): void {
  const config = app.get(ConfigService);
  const nodeEnv = config.get<string>('NODE_ENV');
  const isProd = isProductionEnv(nodeEnv);
  const enabled =
    !isProd || config.get<string>('SWAGGER_ENABLED') === 'true';

  if (!enabled) {
    return;
  }

  const swaggerUser = config.get<string>('SWAGGER_USER');
  const swaggerPassword = config.get<string>('SWAGGER_PASSWORD');

  if (isProd && (!swaggerUser || !swaggerPassword)) {
    throw new Error(
      'SWAGGER_USER and SWAGGER_PASSWORD are required when SWAGGER_ENABLED=true in production',
    );
  }

  if (isProd && swaggerUser && swaggerPassword) {
    app.use(ROUTES.DOCS, (req: Request, res: Response, next: NextFunction) => {
      const header = req.headers.authorization ?? '';
      const [scheme, encoded] = header.split(' ');
      if (scheme !== 'Basic' || !encoded) {
        res.setHeader('WWW-Authenticate', 'Basic realm="API Docs"');
        res.status(401).send('Authentication required');
        return;
      }
      const decoded = Buffer.from(encoded, 'base64').toString('utf8');
      const [user, pass] = decoded.split(':');
      if (user === swaggerUser && pass === swaggerPassword) {
        next();
        return;
      }
      res.setHeader('WWW-Authenticate', 'Basic realm="API Docs"');
      res.status(401).send('Invalid credentials');
    });
  }

  const document = new DocumentBuilder()
    .setTitle('Garajmarket backend')
    .setDescription("The Garajmarket backend's API")
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const factory = () => SwaggerModule.createDocument(app, document);
  SwaggerModule.setup(ROUTES.DOCS, app, factory);
}

/** Blocks unauthenticated access to debug REST routes in production. */
export function isDebugRouteAllowed(config: ConfigService): boolean {
  if (!isProductionEnv(config.get<string>('NODE_ENV'))) {
    return true;
  }
  return config.get<string>('ALLOW_FIREBASE_DEBUG_ENDPOINT') === 'true';
}
