# NestJS auth reference (backend repo)

Implement in your **Garaj Market API** repository (not shipped inside Flutter app).

## Sessions schema (MongoDB)

```typescript
// sessions.collection
{
  _id: ObjectId,
  userId: ObjectId,
  refreshTokenHash: string,  // sha256(rawRefresh)
  deviceId: string,
  deviceName?: string,
  ip?: string,
  userAgent?: string,
  tokenVersion: number,
  expiresAt: Date,
  revokedAt?: Date,
  createdAt: Date,
  lastUsedAt: Date,
}
```

## Refresh rotation

```typescript
async refreshSession(refreshToken: string, deviceId: string) {
  const hash = sha256(refreshToken);
  const session = await this.sessions.findOne({ refreshTokenHash: hash, revokedAt: null });
  if (!session || session.expiresAt < new Date()) {
    throw new UnauthorizedException({ code: 'INVALID_REFRESH_TOKEN' });
  }
  const user = await this.users.findById(session.userId);
  if (user.tokenVersion !== session.tokenVersion) {
    throw new UnauthorizedException({ code: 'SESSION_REVOKED' });
  }

  const newRefresh = generateSecureToken(48);
  const newHash = sha256(newRefresh);

  await this.sessions.updateOne(
    { _id: session._id },
    { $set: { refreshTokenHash: newHash, lastUsedAt: new Date() } },
  );

  const accessToken = this.jwt.sign(
    { sub: user.id, tv: user.tokenVersion, sid: session._id },
    { secret: ACCESS_SECRET, expiresIn: '15m' },
  );

  return {
    accessToken,
    refreshToken: newRefresh,
    sessionId: session._id.toString(),
    tokenVersion: user.tokenVersion,
    user: { _id: user.id, name: user.name, phone: user.phone },
  };
}
```

## GraphQL errors

```typescript
throw new GraphQLError('Access token expired', {
  extensions: { code: 'TOKEN_EXPIRED' },
});
```

## ValidationPipe (global)

```typescript
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }),
);
```

## Sign-in response shape (backward compatible)

```graphql
type AuthPayload {
  accessToken: String!
  refreshToken: String
  sessionId: String
  tokenVersion: Int
  token: String!      # deprecated alias = accessToken
  user: User!
}
```

## Rate limits (Redis)

| Key | Limit |
|-----|-------|
| `otp:ip:{ip}` | 10 / hour |
| `otp:phone:{phone}` | 5 / hour |
| `ws:conn:{ip}` | 5 / minute |

## Files to add in API repo

- `src/auth/auth.module.ts`
- `src/auth/sessions.service.ts`
- `src/auth/strategies/jwt-access.strategy.ts`
- `src/auth/guards/gql-auth.guard.ts`
- `src/graphql/plugins/alias-limit.plugin.ts`

See `docs/SECURITY_REPORT.md` for full checklist.
