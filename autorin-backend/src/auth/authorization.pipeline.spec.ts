import { INestApplication, Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { Test } from '@nestjs/testing';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { GraphQLModule } from '@nestjs/graphql';
import { Types } from 'mongoose';
import * as jwt from 'jsonwebtoken';
import * as request from 'supertest';
import { AuthGuardsModule } from 'src/auth/auth-guards.module';
import { ContextType } from 'src/auth/interfaces';
import { ownerScope } from 'src/auth/utils/admin-scope';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { ApiErrorCode, formatGraphqlError, throwApi } from 'src/common/errors';
import { UserRoleEnum } from 'src/modules/user/enums';
import { SessionService } from 'src/modules/auth/session/session.service';

const SECRET = 'test-secret-test-secret-test-secret-32';

const sessionMock = {
  assertAccessAllowed: async (payload: { sid?: string }) => {
    if (payload.sid === 'revoked') {
      throwApi(ApiErrorCode.SESSION_REVOKED);
    }
  },
};

@Global()
@Module({
  providers: [{ provide: SessionService, useValue: sessionMock }],
  exports: [SessionService],
})
class TestSessionModule {}

@Resolver()
class AuthzProbeResolver {
  @Query(() => String)
  @UseRole(UserRoleEnum.ADMIN)
  adminSettings(): string {
    return 'settings';
  }

  @Query(() => String)
  @UseRole(UserRoleEnum.ADMIN, UserRoleEnum.MODERATOR)
  moderationQueue(): string {
    return 'queue';
  }

  @Mutation(() => String)
  deleteOwned(
    @Args('ownerId') ownerId: string,
    @Context() context: ContextType,
  ): string {
    const scope = ownerScope(
      context,
      'owner',
      new Types.ObjectId(context.userId),
    );
    if (scope.owner && scope.owner.toString() !== ownerId) {
      throwApi(ApiErrorCode.AUTH_FORBIDDEN);
    }
    return 'deleted';
  }

  @Query(() => String)
  privateAddress(
    @Args('ownerId') ownerId: string,
    @Context() context: ContextType,
  ): string {
    const scope = ownerScope(
      context,
      'author',
      new Types.ObjectId(context.userId),
    );
    if (scope.author && scope.author.toString() !== ownerId) {
      throwApi(ApiErrorCode.AUTH_FORBIDDEN);
    }
    return '12 Secret street';
  }
}

describe('GraphQL authorization pipeline', () => {
  let app: INestApplication;
  const userId = new Types.ObjectId().toString();
  const otherId = new Types.ObjectId().toString();

  beforeAll(async () => {
    process.env.JWT_SECRET = SECRET;
    const moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({ isGlobal: true, ignoreEnvFile: true }),
        TestSessionModule,
        GraphQLModule.forRoot<ApolloDriverConfig>({
          driver: ApolloDriver,
          autoSchemaFile: true,
          path: '/graphql',
          context: ({ req }) => ({ req }),
          formatError: (formatted, error) =>
            formatGraphqlError(formatted, error, { isProduction: true }),
        }),
        AuthGuardsModule,
      ],
      providers: [AuthzProbeResolver],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app?.close();
  });

  function bearer(role: UserRoleEnum, extra: Record<string, unknown> = {}) {
    const token = jwt.sign(
      { userId, userRole: role, sid: 'live', typ: 'access', ...extra },
      SECRET,
      { expiresIn: '5m' },
    );
    return `Bearer ${token}`;
  }

  async function gql(query: string, authorization?: string, variables?: object) {
    const req = request(app.getHttpServer())
      .post('/graphql')
      .send({ query, variables });
    if (authorization) req.set('authorization', authorization);
    const response = await req;
    return response.body;
  }

  it('rejects a guest on an admin query', async () => {
    const body = await gql(`query { adminSettings }`);
    expect(body.errors?.[0]?.message).toBe(ApiErrorCode.AUTH_UNAUTHORIZED);
  });

  it('rejects a user and a moderator on admin settings', async () => {
    for (const role of [UserRoleEnum.USER, UserRoleEnum.MODERATOR]) {
      const body = await gql(`query { adminSettings }`, bearer(role));
      expect(body.data?.adminSettings).toBeUndefined();
      expect(body.errors?.length).toBeGreaterThan(0);
    }
  });

  it('allows an admin and a moderator onto the moderation queue', async () => {
    const admin = await gql(`query { moderationQueue }`, bearer(UserRoleEnum.ADMIN));
    const mod = await gql(
      `query { moderationQueue }`,
      bearer(UserRoleEnum.MODERATOR),
    );
    expect(admin.data.moderationQueue).toBe('queue');
    expect(mod.data.moderationQueue).toBe('queue');
  });

  it('stops a user editing another owner and allows the owner and an admin', async () => {
    const mutation = `mutation($ownerId: String!) { deleteOwned(ownerId: $ownerId) }`;
    const denied = await gql(mutation, bearer(UserRoleEnum.USER), {
      ownerId: otherId,
    });
    expect(denied.errors?.[0]?.message).toBe(ApiErrorCode.AUTH_FORBIDDEN);

    const own = await gql(mutation, bearer(UserRoleEnum.USER), {
      ownerId: userId,
    });
    expect(own.data.deleteOwned).toBe('deleted');

    const admin = await gql(mutation, bearer(UserRoleEnum.ADMIN), {
      ownerId: otherId,
    });
    expect(admin.data.deleteOwned).toBe('deleted');
  });

  it('hides a private address from another user', async () => {
    const query = `query($ownerId: String!) { privateAddress(ownerId: $ownerId) }`;
    const denied = await gql(query, bearer(UserRoleEnum.USER), {
      ownerId: otherId,
    });
    expect(denied.errors?.[0]?.message).toBe(ApiErrorCode.AUTH_FORBIDDEN);

    const allowed = await gql(query, bearer(UserRoleEnum.USER), {
      ownerId: userId,
    });
    expect(allowed.data.privateAddress).toBe('12 Secret street');
  });

  it('rejects an expired access token and a revoked session', async () => {
    const expired = jwt.sign(
      {
        userId,
        userRole: UserRoleEnum.USER,
        sid: 'live',
        exp: Math.floor(Date.now() / 1000) - 10,
      },
      SECRET,
    );
    const expiredBody = await gql(
      `query { moderationQueue }`,
      `Bearer ${expired}`,
    );
    expect(expiredBody.errors?.[0]?.message).toBe(ApiErrorCode.AUTH_TOKEN_EXPIRED);

    const revoked = await gql(
      `query { moderationQueue }`,
      bearer(UserRoleEnum.ADMIN, { sid: 'revoked' }),
    );
    expect(revoked.errors?.[0]?.message).toBe(ApiErrorCode.SESSION_REVOKED);
  });
});
