import { ApolloServerPlugin } from '@apollo/server';
import { BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  fieldExtensionsEstimator,
  getComplexity,
  simpleEstimator,
} from 'graphql-query-complexity';
import { GraphQLError, ValidationRule } from 'graphql';

// graphql-depth-limit is CJS (module.exports) — default import breaks at runtime.
// eslint-disable-next-line @typescript-eslint/no-require-imports
const depthLimit = require('graphql-depth-limit') as (
  maxDepth: number,
) => ValidationRule;

export function createGraphQLValidationRules(config: ConfigService) {
  const maxDepth = Number(config.get('GRAPHQL_MAX_DEPTH') ?? 12);
  return [depthLimit(maxDepth)];
}

/** Blocks expensive queries after the operation is resolved (Apollo plugin). */
export function createComplexityPlugin(
  config: ConfigService,
): ApolloServerPlugin {
  const maxComplexity = Number(config.get('GRAPHQL_MAX_COMPLEXITY') ?? 1000);

  return {
    async requestDidStart() {
      return {
        async didResolveOperation(requestContext) {
          const { schema, document, operationName, request } = requestContext;
          if (!schema || !document) return;

          const complexity = getComplexity({
            schema,
            operationName: operationName ?? undefined,
            query: document,
            variables: request.variables ?? {},
            estimators: [
              fieldExtensionsEstimator(),
              simpleEstimator({ defaultComplexity: 1 }),
            ],
          });

          if (complexity > maxComplexity) {
            throw new GraphQLError(
              `Query complexity ${complexity} exceeds limit ${maxComplexity}`,
            );
          }
        },
      };
    },
  };
}

/** Reject oversized raw GraphQL payloads before parsing (DoS mitigation). */
export function createMaxQuerySizeMiddleware(
  config: ConfigService,
): (req: { body?: unknown; headers?: Record<string, unknown> }, res: unknown, next: () => void) => void {
  const maxBytes = Number(config.get('GRAPHQL_MAX_QUERY_BYTES') ?? 64_000);

  return (req, _res, next) => {
    const contentType = String(
      req.headers?.['content-type'] ?? '',
    ).toLowerCase();
    // GraphQL file uploads (multipart/form-data) include binary parts — size
    // is enforced by Apollo `uploads.maxFileSize`, not this JSON query cap.
    if (contentType.startsWith('multipart/form-data')) {
      next();
      return;
    }

    const contentLength = Number(req.headers?.['content-length'] ?? 0);
    if (contentLength > maxBytes) {
      throw new BadRequestException('GraphQL request body too large');
    }

    const body = req.body;
    if (typeof body === 'string' && Buffer.byteLength(body, 'utf8') > maxBytes) {
      throw new BadRequestException('GraphQL request body too large');
    }

    if (body && typeof body === 'object') {
      const serialized = JSON.stringify(body);
      if (Buffer.byteLength(serialized, 'utf8') > maxBytes) {
        throw new BadRequestException('GraphQL request body too large');
      }
    }

    next();
  };
}
