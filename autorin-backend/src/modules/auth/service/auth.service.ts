import { Injectable, Logger } from '@nestjs/common';
import { ApiErrorCode, throwApi } from 'src/common/errors';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  COLLECTIONS,
  OTP_CODE_EXPIRATION,
  OTP_CODE_LENGTH,
} from 'src/constants';
import { User } from 'src/modules/user/schema';
import { ConfirmSignUpArgs, SignInArgs, SignUpArgs } from '../dto';
import { OtpTokenPayload } from '../interfaces';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { randomInt } from 'crypto';
import { ConfigService } from '@nestjs/config';
import { SmsService } from 'src/utils/sms';
import { AuthOutput, ConfirmationOutput } from '../types';
import { UserRoleEnum } from 'src/modules/user/enums';
import { AuthTokenPayload } from 'src/auth/interfaces';
import { isProductionEnv } from 'src/configs/env';
import { AnalyticsService } from 'src/modules/analytics/service/analytics.service';
import {
  normalizeUzPhone,
  uzPhoneLookupVariants,
} from 'src/shared/utils/normalize-uz-phone';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectModel(COLLECTIONS.USERS) private userModel: Model<User>,
    private configService: ConfigService,
    private smsService: SmsService,
    private analyticsService: AnalyticsService,
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

    const otp = this.normalizeOtpCode(code);
    const isCodeValid = await bcrypt.compare(otp, payload.code);

    if (!isCodeValid) {
      throwApi(ApiErrorCode.AUTH_INVALID_OTP, { debug: 'OTP bcrypt mismatch' });
    }

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

    const tokenPayload: AuthTokenPayload = {
      userId: createdUser._id.toString(),
      userRole: createdUser.role,
    };

    const authToken = jwt.sign(tokenPayload, this.jwtSecret);

    void this.analyticsService.recordVisit(createdUser._id);

    return { token: authToken, user: createdUser };
  }

  async signIn({ data }: SignInArgs): Promise<AuthOutput> {
    const user = await this.userModel.findOne({
      phone: { $in: uzPhoneLookupVariants(data.phone) },
    });

    if (!user) {
      throwApi(ApiErrorCode.AUTH_USER_NOT_FOUND, {
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

    const tokenPayload: AuthTokenPayload = {
      userId: user._id.toString(),
      userRole: user.role,
    };
    const token = jwt.sign(tokenPayload, this.jwtSecret);

    void this.analyticsService.recordVisit(user._id);

    return { token, user };
  }
}
