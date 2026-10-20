import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpStatus } from '@nestjs/common';
import { ApiErrorCode, throwApi } from 'src/common/errors';
import { isProductionEnv } from 'src/configs/env';

/**
 * SMS transport.
 * development: `log` prints the code in the server terminal.
 * production: `http` posts `{ to, message }` to SMS_HTTP_URL.
 * The log transport is refused in production so codes never hit logs there.
 */
@Injectable()
export class SmsService {
  private readonly logger = new Logger('SMS');

  constructor(private readonly config: ConfigService) {}

  async sendSms(to: string, message: string): Promise<void> {
    const nodeEnv = this.config.get<string>('NODE_ENV');
    const provider = (this.config.get<string>('SMS_PROVIDER') ?? '').trim();
    const production = isProductionEnv(nodeEnv);

    if (production && provider !== 'http') {
      this.logger.error('SMS_PROVIDER=http is required in production');
      throwApi(ApiErrorCode.SMS_UNAVAILABLE, {
        status: HttpStatus.SERVICE_UNAVAILABLE,
        debug: 'SMS provider is not configured',
      });
    }

    if (!production && (provider === '' || provider === 'log')) {
      this.logDevelopmentSms(to, message);
      return;
    }

    if (provider === 'http') {
      await this.postHttp(to, message);
      return;
    }

    throwApi(ApiErrorCode.SMS_UNAVAILABLE, {
      status: HttpStatus.SERVICE_UNAVAILABLE,
      debug: 'SMS provider is not configured',
    });
  }

  private logDevelopmentSms(to: string, message: string) {
    const otp = message.match(/\b(\d{5})\b/)?.[1];
    this.logger.warn(`DEV SMS to ${to}${otp ? ` code ${otp}` : ''}`);
  }

  private async postHttp(to: string, message: string) {
    const url = this.config.get<string>('SMS_HTTP_URL')?.trim();
    if (!url) {
      throwApi(ApiErrorCode.SMS_UNAVAILABLE, {
        status: HttpStatus.SERVICE_UNAVAILABLE,
        debug: 'SMS_HTTP_URL is empty',
      });
    }
    const token = this.config.get<string>('SMS_HTTP_TOKEN') ?? '';
    const timeoutMs = Number(this.config.get('SMS_HTTP_TIMEOUT_MS') ?? 8000);
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        ...(token ? { authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify({ to, message }),
      signal: AbortSignal.timeout(
        Number.isFinite(timeoutMs) && timeoutMs > 0 ? timeoutMs : 8000,
      ),
    });
    if (!response.ok) {
      this.logger.error(`SMS provider HTTP ${response.status}`);
      throwApi(ApiErrorCode.SMS_UNAVAILABLE, {
        status: HttpStatus.SERVICE_UNAVAILABLE,
        debug: 'SMS provider rejected the message',
      });
    }
  }
}
