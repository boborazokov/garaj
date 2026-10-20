import { ApolloServerPlugin } from '@apollo/server';
import {
  ApolloServerPluginInlineTraceDisabled,
  ApolloServerPluginLandingPageDisabled,
} from '@apollo/server/plugin/disabled';
import { ApolloServerPluginLandingPageLocalDefault } from '@apollo/server/plugin/landingPage/default';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { Logger, Module } from '@nestjs/common';
import { Request } from 'express';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { GraphQLModule } from '@nestjs/graphql';
import * as jwt from 'jsonwebtoken';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { ROUTES } from 'src/constants';
import { UserRoleEnum } from 'src/modules/user/enums';
import { formatGraphqlError } from 'src/common/errors';
import { isProductionEnv, parseAllowedOrigins } from '../env';
import {
  createComplexityPlugin,
  createGraphQLValidationRules,
} from './graphql-security.validation';
import {
  assertWsOriginAllowed,
  verifyWsToken,
  WsConnectionLimiter,
} from './ws-connection-limiter';
import { SessionService } from 'src/modules/auth/session/session.service';

const wsLogger = new Logger('GraphQL-WS');

/** Exported into GraphQLModule.forRootAsync — dynamic module cannot see parent providers. */
@Module({
  imports: [ConfigModule],
  providers: [WsConnectionLimiter],
  exports: [WsConnectionLimiter],
})
class WsConnectionLimiterModule {}

@Module({
  imports: [
    GraphQLModule.forRootAsync<ApolloDriverConfig>({
      imports: [ConfigModule, WsConnectionLimiterModule],
      inject: [ConfigService, WsConnectionLimiter],
      driver: ApolloDriver,
      useFactory: async (
        config: ConfigService,
        wsLimiter: WsConnectionLimiter,
      ) => {
        const nodeEnv = config.get<string>('NODE_ENV') ?? 'development';
        const isProd = isProductionEnv(nodeEnv);
        const jwtSecret = config.getOrThrow<string>('JWT_SECRET');
        const allowedOrigins = parseAllowedOrigins(
          config.get<string>('ALLOWED_ORIGINS'),
        );

        const securityPlugins: ApolloServerPlugin[] = [
          createComplexityPlugin(config),
          ...(isProd
            ? [
                ApolloServerPluginLandingPageDisabled(),
                ApolloServerPluginInlineTraceDisabled(),
              ]
            : [
                ApolloServerPluginLandingPageLocalDefault({
                  embed: true,
                }) as unknown as ApolloServerPlugin,
              ]),
        ];

        return {
          path: ROUTES.API,
          autoSchemaFile: 'schema.gql',
          playground: false,
          introspection: !isProd,
          csrfPrevention: true,
          uploads: {
            maxFileSize: Number(config.get('UPLOAD_MAX_FILE_BYTES') ?? 10_485_760),
            maxFiles: 10,
          },
          validationRules: createGraphQLValidationRules(config),

          formatError: (formattedError, error) =>
            formatGraphqlError(formattedError, error, { isProduction: isProd }),

          subscriptions: {
            'graphql-ws': {
              onConnect: async (ctx: any) => {
                const headerOrigin = ctx.extra?.request?.headers?.origin;
                const origin =
                  (typeof headerOrigin === 'string' ? headerOrigin : undefined) ??
                  (ctx.connectionParams?.['origin'] as string) ??
                  (ctx.connectionParams?.['Origin'] as string);
                assertWsOriginAllowed(origin, allowedOrigins, isProd);

                const params = ctx.connectionParams ?? {};
                const raw =
                  (params['authorization'] as string) ??
                  (params['Authorization'] as string) ??
                  '';
                const identity = verifyWsToken(raw, jwtSecret, jwt);
                await SessionService.assertHandshake({
                  userId: identity.userId.toString(),
                  userRole: identity.userRole,
                  sid: identity.sid,
                });
                wsLimiter.assertHandshakeAllowed(identity.userId);
                const socketId = wsLimiter.attachSocketId(ctx);
                wsLimiter.register(identity.userId, socketId);

                if (!ctx.extra) ctx.extra = {};
                ctx.extra.userId = identity.userId;
                ctx.extra.userRole = identity.userRole;
                ctx.extra.socketId = socketId;
                wsLogger.log(
                  `WS handshake OK: user=${identity.userId.toString()}`,
                );
              },
              onDisconnect: (ctx: any) => {
                wsLimiter.releaseFromContext(ctx);
                const uid = ctx?.extra?.userId;
                if (uid) wsLogger.log(`WS disconnect: user=${uid.toString()}`);
              },
            },

            'subscriptions-transport-ws': {
              onConnect: async (params: Record<string, unknown>) => {
                const origin =
                  (params['origin'] as string) ??
                  (params['Origin'] as string);
                assertWsOriginAllowed(origin, allowedOrigins, isProd);

                const raw =
                  (params['authorization'] as string) ??
                  (params['Authorization'] as string) ??
                  '';
                const identity = verifyWsToken(raw, jwtSecret, jwt);
                await SessionService.assertHandshake({
                  userId: identity.userId.toString(),
                  userRole: identity.userRole,
                  sid: identity.sid,
                });
                wsLimiter.assertHandshakeAllowed(identity.userId);
                return {
                  userId: identity.userId,
                  userRole: identity.userRole,
                };
              },
            },
          },

          context: ({
            req,
            extra,
            connection,
          }: {
            req?: Record<string, unknown>;
            extra?: { userId?: Types.ObjectId; userRole?: UserRoleEnum };
            connection?: {
              context?: { userId?: Types.ObjectId; userRole?: UserRoleEnum };
            };
          }) => {
            if (extra?.userId) {
              return {
                extra,
                userId: extra.userId,
                userRole: extra.userRole,
                isAuthenticated: true,
              };
            }
            if (connection?.context?.userId) {
              return {
                connection,
                userId: connection.context.userId,
                userRole: connection.context.userRole,
                isAuthenticated: true,
              };
            }
            if (req && typeof req === 'object' && 'headers' in req) {
              const httpReq = req as unknown as Request;
              return Object.assign(httpReq, {
                req: httpReq,
                res: httpReq.res,
              });
            }
            return req;
          },

          plugins: securityPlugins,
        };
      },
    }),
  ],
  providers: [ObjectIdScalar],
})
export class GraphqlConfig {}
