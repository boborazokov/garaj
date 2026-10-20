import { spawn } from 'child_process';
import Redis from 'ioredis';
import { OtpProtection } from '../otp/otp-protection';

function redisClient() {
  return new Redis({
    host: '127.0.0.1',
    port: 6379,
    db: 15,
    maxRetriesPerRequest: 1,
    connectTimeout: 2000,
    lazyConnect: true,
  });
}

class LiveRedisStore {
  constructor(private readonly redis: Redis) {}
  async get(key: string) {
    const raw = await this.redis.get(key);
    return raw ? Number(raw) : 0;
  }
  async increment(key: string, ttlMs: number) {
    const count = await this.redis.incr(key);
    if (count === 1) await this.redis.pexpire(key, ttlMs);
    return count;
  }
  async consumeOnce(key: string, ttlMs: number) {
    const result = await this.redis.set(key, '1', 'PX', ttlMs, 'NX');
    return result === 'OK';
  }
}

describe('OTP limits on Redis', () => {
  const redis = redisClient();

  beforeAll(async () => {
    await redis.connect();
    await redis.flushdb();
  });

  afterAll(async () => {
    await redis.flushdb();
    await redis.quit();
  });

  it('shares five attempts across two clients and keeps them after a new client', async () => {
    const token = 'shared-otp-token';
    const first = new OtpProtection(new LiveRedisStore(redis));
    const secondRedis = redisClient();
    await secondRedis.connect();
    const second = new OtpProtection(new LiveRedisStore(secondRedis));

    for (let i = 0; i < 5; i++) {
      expect(await first.assertAllowed(token)).toBe(true);
      await second.recordFailure(token);
    }
    await secondRedis.quit();

    const afterRestart = redisClient();
    await afterRestart.connect();
    const third = new OtpProtection(new LiveRedisStore(afterRestart));
    expect(await third.assertAllowed(token)).toBe(false);
    expect(await third.consume(token)).toBe(true);
    expect(await first.consume(token)).toBe(false);
    await afterRestart.quit();
  });

  it('counts increments from two processes', async () => {
    const script = `
      const Redis = require('ioredis');
      const redis = new Redis({ host: '127.0.0.1', port: 6379, db: 15 });
      redis.incr('otp:procs').then((n) => redis.quit().then(() => {
        process.stdout.write(String(n));
      }));
    `;
    const run = () =>
      new Promise<string>((resolve, reject) => {
        const child = spawn(process.execPath, ['-e', script], {
          cwd: process.cwd(),
        });
        let out = '';
        child.stdout.on('data', (chunk) => {
          out += chunk.toString();
        });
        child.on('exit', (code) => {
          if (code === 0) resolve(out);
          else reject(new Error(`child exit ${code}`));
        });
      });
    const values = (await Promise.all([run(), run()])).map(Number).sort();
    expect(values).toEqual([1, 2]);
  });
});
