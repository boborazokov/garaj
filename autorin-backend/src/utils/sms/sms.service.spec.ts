import { createServer, Server } from 'http';
import { AddressInfo } from 'net';
import { ConfigService } from '@nestjs/config';
import { ApiException } from 'src/common/errors';
import { SmsService } from './sms.service';

function config(values: Record<string, string>): ConfigService {
  return { get: (key: string) => values[key] } as ConfigService;
}

describe('SmsService', () => {
  let server: Server;
  let url: string;
  const hits: { authorization?: string; body?: { to?: string; message?: string } }[] =
    [];

  beforeAll(async () => {
    server = createServer((req, res) => {
      const chunks: Buffer[] = [];
      req.on('data', (chunk) => chunks.push(chunk));
      req.on('end', () => {
        const body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
        hits.push({
          authorization: req.headers.authorization,
          body,
        });
        if (body.to === 'reject') {
          res.writeHead(400).end('no');
          return;
        }
        res.writeHead(200).end('ok');
      });
    });
    await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
    const address = server.address() as AddressInfo;
    url = `http://127.0.0.1:${address.port}/send`;
  });

  afterAll(async () => {
    await new Promise<void>((resolve, reject) =>
      server.close((err) => (err ? reject(err) : resolve())),
    );
  });

  beforeEach(() => {
    hits.length = 0;
  });

  it('refuses the log transport in production', async () => {
    const sms = new SmsService(
      config({ NODE_ENV: 'production', SMS_PROVIDER: 'log' }),
    );
    await expect(sms.sendSms('+998901112233', 'code 12345')).rejects.toBeInstanceOf(
      ApiException,
    );
    expect(hits).toHaveLength(0);
  });

  it('posts one JSON message with the bearer token and does not retry', async () => {
    const sms = new SmsService(
      config({
        NODE_ENV: 'production',
        SMS_PROVIDER: 'http',
        SMS_HTTP_URL: url,
        SMS_HTTP_TOKEN: 'provider-token',
      }),
    );
    await sms.sendSms('+998901112233', 'Your OTP code is: 12345');
    expect(hits).toHaveLength(1);
    expect(hits[0].authorization).toBe('Bearer provider-token');
    expect(hits[0].body).toEqual({
      to: '+998901112233',
      message: 'Your OTP code is: 12345',
    });
  });

  it('fails when the provider rejects the message', async () => {
    const sms = new SmsService(
      config({
        NODE_ENV: 'production',
        SMS_PROVIDER: 'http',
        SMS_HTTP_URL: url,
      }),
    );
    await expect(sms.sendSms('reject', 'code 00000')).rejects.toBeInstanceOf(
      ApiException,
    );
    expect(hits).toHaveLength(1);
  });

  it('fails when the provider does not answer before the timeout', async () => {
    const hung = createServer(() => undefined);
    await new Promise<void>((resolve) => hung.listen(0, '127.0.0.1', resolve));
    const address = hung.address() as AddressInfo;
    const sms = new SmsService(
      config({
        NODE_ENV: 'production',
        SMS_PROVIDER: 'http',
        SMS_HTTP_URL: `http://127.0.0.1:${address.port}/send`,
        SMS_HTTP_TIMEOUT_MS: '200',
      }),
    );
    await expect(sms.sendSms('+998901112233', 'code 12345')).rejects.toBeTruthy();
    await new Promise<void>((resolve, reject) =>
      hung.close((err) => (err ? reject(err) : resolve())),
    );
  });
});
