import { Injectable, Logger, HttpStatus } from '@nestjs/common';
import { ApiErrorCode, throwApi } from 'src/common/errors';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  COLLECTIONS,
  OTP_CODE_EXPIRATION,
  OTP_CODE_LENGTH,
} from 'src/constants';
import { User } from 'src/modules/user/schema';
import {
  ConfirmSignUpArgs,
  RequestPasswordResetArgs,
  ResetPasswordArgs,
  SignInArgs,
  SignUpArgs,
} from '../dto';
import { OtpTokenPayload } from '../interfaces';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { signAccessToken } from '../session/session.logic';
import { randomInt } from 'crypto';
import { ConfigService } from '@nestjs/config';
import { SmsService } from 'src/utils/sms';
import { AuthOutput, ConfirmationOutput } from '../types';
import { UserRoleEnum } from 'src/modules/user/enums';
import { isProductionEnv } from 'src/configs/env';
import { AnalyticsService } from 'src/modules/analytics/service/analytics.service';
import {
  normalizeUzPhone,
  uzPhoneLookupVariants,
} from 'src/shared/utils/normalize-uz-phone';
import { OtpProtectionService } from '../otp/otp-protection.service';
import { OtpStoreUnavailableError } from '../otp/otp-protection';
import { SessionService } from '../session/session.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private dummyPasswordHash?: string;

  constructor(
    @InjectModel(COLLECTIONS.USERS) private userModel: Model<User>,
    private configService: ConfigService,
    private smsService: SmsService,
    private analyticsService: AnalyticsService,
    private sessions: SessionService,
    private otp: OtpProtectionService,
  ) {}

  private get jwtSecret(): string {
    return this.configService.getOrThrow<string>('JWT_SECRET');
  }

  /** Always exactly 5 digits (leading zeros preserved). */
  private generateOtpCode(): string {
    return String(randomInt(0, 10 ** OTP_CODE_LENGTH)).padStart(
      OTP_CODE_LENGTH,
      '0',
    );
  }

  private normalizeOtpCode(raw: string): string {
    const digits = String(raw ?? '')
      .trim()
      .replace(/\D/g, '');
    return digits.padStart(OTP_CODE_LENGTH, '0').slice(-OTP_CODE_LENGTH);
  }

  private normalizeConfirmationToken(raw?: string): string {
    let t = raw?.trim() ?? '';
    if (t.toLowerCase().startsWith('bearer ')) {
      t = t.slice(7).trim();
    }
    return t;
  }

  async signUp({ data }: SignUpArgs): Promise<ConfirmationOutput> {
    const foundUser = await this.userModel.findOne({
      phone: { $in: uzPhoneLookupVariants(data.phone) },
    });

    if (foundUser) {
      throwApi(ApiErrorCode.AUTH_USER_EXISTS, {
        debug: 'Phone already registered',
      });
    }

    const code = this.generateOtpCode();

    if (!isProductionEnv(this.configService.get<string>('NODE_ENV'))) {
      this.logger.warn(`DEV OTP for ${data.phone}: ${code}`);
    }

    await this.smsService.sendSms(data.phone, `Your OTP code is: ${code}`);

    const codeHash = await bcrypt.hash(code, 10);

    const tokenPayload: OtpTokenPayload = {
      code: codeHash,
      data,
    };

    const token = jwt.sign(tokenPayload, this.jwtSecret, {
      expiresIn: OTP_CODE_EXPIRATION,
    });

    const output: ConfirmationOutput = { token };

    if (!isProductionEnv(this.configService.get<string>('NODE_ENV'))) {
      output.correctCode = Number(code);
    }

    return output;
  }

  async confirmSignUp({ code, token }: ConfirmSignUpArgs) {
    const signupToken = this.normalizeConfirmationToken(token);
    if (!signupToken || signupToken.split('.').length !== 3) {
      throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_MISSING, {
        debug: 'Missing or malformed JWT confirmation token',
      });
    }

    let payload: OtpTokenPayload;
    try {
      payload = jwt.verify(signupToken, this.jwtSecret) as OtpTokenPayload;
    } catch (err) {
      if (err instanceof jwt.TokenExpiredError) {
        throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_EXPIRED, {
          debug: 'JWT confirmation token expired',
        });
      }
      this.logger.warn(
        `confirmSignUp jwt verify failed: ${(err as Error).name}`,
      );
      throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_INVALID, {
        debug: 'JWT verification failed',
      });
    }

    if (!payload?.code || !payload?.data) {
      throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_INVALID, {
        debug: 'JWT payload missing code or data',
      });
    }

    await this.assertOtpAttempts(signupToken);
    const otp = this.normalizeOtpCode(code);
    const isCodeValid = await bcrypt.compare(otp, payload.code);

    if (!isCodeValid) {
      await this.recordOtpFailure(signupToken);
      throwApi(ApiErrorCode.AUTH_INVALID_OTP, { debug: 'OTP bcrypt mismatch' });
    }
    await this.consumeOtp(signupToken);

    const { data } = payload;

    const formattedPhone = normalizeUzPhone(data.phone);

    const existingUser = await this.userModel.findOne({
      phone: { $in: uzPhoneLookupVariants(formattedPhone) },
    });

    if (existingUser) {
      throwApi(ApiErrorCode.AUTH_USER_EXISTS, {
        debug: 'User created between signUp and confirm',
      });
    }

    const createdUser = new this.userModel({
      name: data.name,
      phone: formattedPhone,
      password: data.password,
      role: UserRoleEnum.USER,
    });

    await createdUser.save();

    void this.analyticsService.recordVisit(createdUser._id);

    return this.issueAuthOutput(createdUser);
  }

  async signIn({ data }: SignInArgs): Promise<AuthOutput> {
    const user = await this.userModel.findOne({
      phone: { $in: uzPhoneLookupVariants(data.phone) },
    });

    if (!user) {
      await bcrypt.compare(data.password, await this.passwordDummyHash());
      throwApi(ApiErrorCode.AUTH_INVALID_CREDENTIALS, {
        debug: 'No user for phone',
      });
    }

    if (user.deletedAt) {
      throwApi(ApiErrorCode.AUTH_ACCOUNT_DELETED, {
        debug: 'Account was deleted',
      });
    }

    const isValid = await bcrypt.compare(data.password, user.password);

    if (!isValid) {
      throwApi(ApiErrorCode.AUTH_INVALID_CREDENTIALS, {
        debug: 'Password mismatch',
      });
    }

    void this.analyticsService.recordVisit(user._id);

    return this.issueAuthOutput(user);
  }

  /**
   * Sends a 5-digit code. The stored password is hashed, so the SMS
   * never contains the old password — the user sets a new one after the code.
   */
  async requestPasswordReset({
    phone,
  }: RequestPasswordResetArgs): Promise<ConfirmationOutput> {
    const user = await this.userModel.findOne({
      phone: { $in: uzPhoneLookupVariants(phone) },
    });

    if (!user || user.deletedAt) {
      return this.decoyResetConfirmation();
    }

    const formattedPhone = normalizeUzPhone(phone);
    const code = this.generateOtpCode();

    if (!isProductionEnv(this.configService.get<string>('NODE_ENV'))) {
      this.logger.warn(`DEV password-reset OTP for ${formattedPhone}: ${code}`);
    }

    await this.smsService.sendSms(
      formattedPhone,
      `Your OTP code is: ${code}`,
    );

    const token = jwt.sign(
      {
        code: await bcrypt.hash(code, 10),
        phone: formattedPhone,
        purpose: 'password_reset',
      },
      this.jwtSecret,
      { expiresIn: OTP_CODE_EXPIRATION },
    );

    const output: ConfirmationOutput = { token };
    if (!isProductionEnv(this.configService.get<string>('NODE_ENV'))) {
      output.correctCode = Number(code);
    }
    return output;
  }

  async resetPassword({ token, code, password }: ResetPasswordArgs) {
    const resetToken = this.normalizeConfirmationToken(token);
    if (!resetToken || resetToken.split('.').length !== 3) {
      throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_MISSING, {
        debug: 'Missing password-reset token',
      });
    }

    let payload: { code?: string; phone?: string; purpose?: string };
    try {
      payload = jwt.verify(resetToken, this.jwtSecret) as typeof payload;
    } catch (err) {
      if (err instanceof jwt.TokenExpiredError) {
        throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_EXPIRED, {
          debug: 'Password-reset token expired',
        });
      }
      throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_INVALID, {
        debug: 'Password-reset token invalid',
      });
    }

    if (payload.purpose !== 'password_reset' || !payload.code || !payload.phone) {
      throwApi(ApiErrorCode.AUTH_CONFIRMATION_TOKEN_INVALID, {
        debug: 'Password-reset payload mismatch',
      });
    }

    await this.assertOtpAttempts(resetToken);
    const otp = this.normalizeOtpCode(code);
    const isCodeValid = await bcrypt.compare(otp, payload.code);
    if (!isCodeValid) {
      await this.recordOtpFailure(resetToken);
      throwApi(ApiErrorCode.AUTH_INVALID_OTP, { debug: 'Reset OTP mismatch' });
    }
    await this.consumeOtp(resetToken);

    const user = await this.userModel.findOne({
      phone: { $in: uzPhoneLookupVariants(payload.phone) },
    });
    if (!user || user.deletedAt) {
      throwApi(ApiErrorCode.AUTH_USER_NOT_FOUND, {
        debug: 'User missing at password reset',
      });
    }

    user.password = password;
    await user.save();
    await this.sessions.revokeAllForUser(user._id);
    return true;
  }

  async refreshSession(refreshToken: string, deviceId: string): Promise<AuthOutput> {
    const rotated = await this.sessions.rotate(refreshToken, deviceId);
    const user = await this.userModel.findById(rotated.userId);
    if (!user || user.deletedAt) {
      await this.sessions.revokeAllForUser(rotated.userId);
      throwApi(ApiErrorCode.SESSION_REVOKED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'User missing during refresh',
      });
    }
    return this.issueAuthOutputForSession(user, rotated);
  }

  async logoutSession(refreshToken: string): Promise<boolean> {
    await this.sessions.revoke(refreshToken);
    return true;
  }

  async logoutAllDevices(userId: string): Promise<boolean> {
    await this.sessions.revokeAllForUser(userId);
    return true;
  }

  private async issueAuthOutput(user: User): Promise<AuthOutput> {
    const session = await this.sessions.create(user._id);
    return this.issueAuthOutputForSession(user, session);
  }

  private issueAuthOutputForSession(
    user: User,
    session: { sessionId: string; refreshToken: string },
  ): AuthOutput {
    const accessToken = signAccessToken(
      {
        userId: user._id.toString(),
        userRole: user.role,
        sid: session.sessionId,
        typ: 'access',
      },
      this.jwtSecret,
      this.sessions.accessTtl(),
      (payload, secret, options) => jwt.sign(payload, secret, options),
      jwt.decode,
    );
    return {
      token: accessToken,
      accessToken,
      refreshToken: session.refreshToken,
      sessionId: session.sessionId,
      tokenVersion: 1,
      user,
    };
  }

  private async assertOtpAttempts(token: string) {
    let allowed = true;
    try {
      allowed = await this.otp.assertAllowed(token);
    } catch (err) {
      if (err instanceof OtpStoreUnavailableError) {
        throwApi(ApiErrorCode.AUTH_OTP_UNAVAILABLE, {
          status: HttpStatus.SERVICE_UNAVAILABLE,
          debug: 'OTP store unavailable',
        });
      }
      throw err;
    }
    if (!allowed) {
      throwApi(ApiErrorCode.AUTH_OTP_EXPIRED, {
        debug: 'Too many OTP attempts',
      });
    }
  }

  private async recordOtpFailure(token: string) {
    try {
      await this.otp.recordFailure(token);
    } catch (err) {
      if (err instanceof OtpStoreUnavailableError) {
        throwApi(ApiErrorCode.AUTH_OTP_UNAVAILABLE, {
          status: HttpStatus.SERVICE_UNAVAILABLE,
          debug: 'OTP store unavailable',
        });
      }
      throw err;
    }
  }

  private async consumeOtp(token: string) {
    let fresh = false;
    try {
      fresh = await this.otp.consume(token);
    } catch (err) {
      if (err instanceof OtpStoreUnavailableError) {
        throwApi(ApiErrorCode.AUTH_OTP_UNAVAILABLE, {
          status: HttpStatus.SERVICE_UNAVAILABLE,
          debug: 'OTP store unavailable',
        });
      }
      throw err;
    }
    if (!fresh) {
      throwApi(ApiErrorCode.AUTH_INVALID_OTP, {
        debug: 'OTP already used',
      });
    }
  }

  /** Same shape as a real reset so the response does not reveal whether the phone exists. */
  private async decoyResetConfirmation(): Promise<ConfirmationOutput> {
    const token = jwt.sign(
      {
        code: await bcrypt.hash(this.generateOtpCode(), 10),
        phone: 'unknown',
        purpose: 'password_reset',
      },
      this.jwtSecret,
      { expiresIn: OTP_CODE_EXPIRATION },
    );
    return { token };
  }

  private async passwordDummyHash() {
    if (!this.dummyPasswordHash) {
      this.dummyPasswordHash = await bcrypt.hash('not-a-user', 10);
    }
    return this.dummyPasswordHash;
  }
}
