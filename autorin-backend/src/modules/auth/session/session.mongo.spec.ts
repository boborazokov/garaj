import { Types } from 'mongoose';
import { ApiException } from 'src/common/errors';
import { AuthSessionSchema } from '../schema/auth-session.schema';
import { SessionService } from './session.service';
import mongoose from 'mongoose';

const uri =
  process.env.SESSION_TEST_DATABASE_URL ??
  'mongodb://127.0.0.1:27017/autorin_session_test';

describe('auth sessions on MongoDB', () => {
  let service: SessionService;

  beforeAll(async () => {
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 2500 });
    await mongoose.connection.dropDatabase();
    const model =
      mongoose.models.AuthSessionTest ??
      mongoose.model('AuthSessionTest', AuthSessionSchema, 'auth_sessions');
    service = new SessionService(model as never, {
      get: () => undefined,
    } as never);
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  it('rotates once, treats a parallel refresh as a conflict, then revokes reuse', async () => {
    const userId = new Types.ObjectId();
    const issued = await service.create(userId, 'device-a');
    const first = issued.refreshToken;

    const [left, right] = await Promise.allSettled([
      service.rotate(first, 'device-a'),
      service.rotate(first, 'device-a'),
    ]);
    const ok = [left, right].filter((item) => item.status === 'fulfilled');
    const conflict = [left, right].filter((item) => item.status === 'rejected');
    expect(ok).toHaveLength(1);
    expect(conflict).toHaveLength(1);
    expect((conflict[0] as PromiseRejectedResult).reason).toBeInstanceOf(
      ApiException,
    );

    const winner = (ok[0] as PromiseFulfilledResult<{ refreshToken: string }>)
      .value.refreshToken;
    await expect(service.rotate(first, 'device-a')).rejects.toBeInstanceOf(
      ApiException,
    );

    const model = mongoose.model('AuthSessionTest');
    await model.updateOne(
      { currentHash: { $exists: true }, userId },
      { $set: { rotatedAt: new Date(Date.now() - 20_000) } },
    );
    await expect(service.rotate(first, 'device-a')).rejects.toMatchObject({
      apiCode: 'SESSION_REVOKED',
    });
    await expect(service.rotate(winner, 'device-a')).rejects.toBeInstanceOf(
      ApiException,
    );

    const expiredUser = new Types.ObjectId();
    const expired = await service.create(expiredUser);
    await mongoose.model('AuthSessionTest').updateOne(
      { userId: expiredUser },
      { $set: { expiresAt: new Date(Date.now() - 1000) } },
    );
    await expect(service.rotate(expired.refreshToken)).rejects.toMatchObject({
      apiCode: 'INVALID_REFRESH_TOKEN',
    });

    await service.revoke(winner);
  });

  it('keeps a session across a new service instance and drops it on revoke-all', async () => {
    const userId = new Types.ObjectId();
    const issued = await service.create(userId);
    const restarted = new SessionService(
      mongoose.model('AuthSessionTest') as never,
      { get: () => undefined } as never,
    );
    const rotated = await restarted.rotate(issued.refreshToken);
    await restarted.revokeAllForUser(userId);
    await expect(restarted.rotate(rotated.refreshToken)).rejects.toBeInstanceOf(
      ApiException,
    );
  });
});
