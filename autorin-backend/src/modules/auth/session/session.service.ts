import { HttpStatus, Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ApiErrorCode, throwApi } from 'src/common/errors';
import { COLLECTIONS } from 'src/constants';
import { AuthTokenPayload } from 'src/auth/interfaces';
import { AuthSession } from '../schema/auth-session.schema';
import {
  decideRefresh,
  DEFAULT_LEGACY_ACCESS_UNTIL,
  hashRefreshToken,
  legacyAccessStillValid,
  newRefreshToken,
} from './session.logic';

const ACCESS_TTL = '15m';
const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;

export type IssuedSession = {
  sessionId: string;
  refreshToken: string;
  userId: string;
};

@Injectable()
export class SessionService implements OnModuleInit {
  private static current: SessionService | null = null;

  constructor(
    @InjectModel(COLLECTIONS.AUTH_SESSIONS)
    private readonly sessions: Model<AuthSession>,
    private readonly config: ConfigService,
  ) {}

  onModuleInit() {
    SessionService.current = this;
  }

  static assertHandshake(payload: AuthTokenPayload) {
    if (!SessionService.current) return Promise.resolve();
    return SessionService.current.assertAccessAllowed(payload);
  }

  accessTtl(): string {
    return this.config.get<string>('ACCESS_TOKEN_TTL') ?? ACCESS_TTL;
  }

  legacyUntilMs(): number {
    const raw =
      this.config.get<string>('LEGACY_ACCESS_TOKEN_UNTIL') ??
      DEFAULT_LEGACY_ACCESS_UNTIL;
    const parsed = Date.parse(raw);
    return Number.isFinite(parsed)
      ? parsed
      : Date.parse(DEFAULT_LEGACY_ACCESS_UNTIL);
  }

  async create(userId: Types.ObjectId, deviceId?: string): Promise<IssuedSession> {
    const refreshToken = newRefreshToken();
    const created = await this.sessions.create({
      userId,
      currentHash: hashRefreshToken(refreshToken),
      expiresAt: new Date(Date.now() + this.refreshTtlMs()),
      deviceId,
    });
    return {
      sessionId: created._id.toString(),
      refreshToken,
      userId: userId.toString(),
    };
  }

  /**
   * Rotates the refresh token. Reuse of an already rotated token revokes the session.
   * A second request inside the grace window does not revoke it.
   */
  async rotate(
    refreshToken: string,
    deviceId?: string,
  ): Promise<IssuedSession> {
    const presented = hashRefreshToken(refreshToken);
    const session = await this.sessions.findOne({
      $or: [{ currentHash: presented }, { previousHash: presented }],
    });

    const decision = decideRefresh(
      session
        ? {
            currentHash: session.currentHash,
            previousHash: session.previousHash,
            expiresAt: session.expiresAt,
            revokedAt: session.revokedAt,
            rotatedAt: session.rotatedAt,
          }
        : null,
      presented,
      Date.now(),
    );

    if (decision.type === 'invalid' || decision.type === 'expired') {
      throwApi(ApiErrorCode.INVALID_REFRESH_TOKEN, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'Refresh token rejected',
      });
    }
    if (decision.type === 'revoked' || decision.type === 'reuse') {
      if (session && decision.type === 'reuse') {
        await this.sessions.updateOne(
          { _id: session._id },
          { $set: { revokedAt: new Date() } },
        );
      }
      throwApi(ApiErrorCode.SESSION_REVOKED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'Refresh token reuse',
      });
    }
    if (decision.type === 'conflict') {
      throwApi(ApiErrorCode.AUTH_REFRESH_CONFLICT, {
        status: HttpStatus.CONFLICT,
        debug: 'Concurrent refresh',
      });
    }

    const next = newRefreshToken();
    const updated = await this.sessions.findOneAndUpdate(
      {
        _id: session!._id,
        currentHash: presented,
        revokedAt: null,
      },
      {
        $set: {
          previousHash: presented,
          currentHash: hashRefreshToken(next),
          rotatedAt: new Date(),
          expiresAt: new Date(Date.now() + this.refreshTtlMs()),
          ...(deviceId ? { deviceId } : {}),
        },
      },
      { new: true },
    );

    if (!updated) {
      throwApi(ApiErrorCode.AUTH_REFRESH_CONFLICT, {
        status: HttpStatus.CONFLICT,
        debug: 'Refresh lost the race',
      });
    }

    return {
      sessionId: updated._id.toString(),
      refreshToken: next,
      userId: updated.userId.toString(),
    };
  }

  async revoke(refreshToken: string): Promise<void> {
    const hash = hashRefreshToken(refreshToken);
    await this.sessions.updateOne(
      { currentHash: hash, revokedAt: null },
      { $set: { revokedAt: new Date() } },
    );
  }

  async revokeAllForUser(userId: Types.ObjectId | string): Promise<void> {
    await this.sessions.updateMany(
      { userId: new Types.ObjectId(userId), revokedAt: null },
      { $set: { revokedAt: new Date() } },
    );
  }

  async assertAccessAllowed(payload: AuthTokenPayload): Promise<void> {
    if (!payload.sid) {
      if (
        legacyAccessStillValid(payload, Date.now(), this.legacyUntilMs())
      ) {
        return;
      }
      throwApi(ApiErrorCode.AUTH_TOKEN_EXPIRED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'Legacy access token past cutoff',
      });
    }

    if (!Types.ObjectId.isValid(payload.sid)) {
      throwApi(ApiErrorCode.SESSION_REVOKED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'Malformed session id',
      });
    }

    const session = await this.sessions.findById(payload.sid);
    if (!session || session.revokedAt || session.expiresAt.getTime() <= Date.now()) {
      throwApi(ApiErrorCode.SESSION_REVOKED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'Session missing or revoked',
      });
    }
    if (session.userId.toString() !== payload.userId) {
      throwApi(ApiErrorCode.SESSION_REVOKED, {
        status: HttpStatus.UNAUTHORIZED,
        debug: 'Session user mismatch',
      });
    }
  }

  private refreshTtlMs(): number {
    const raw = this.config.get<string>('REFRESH_TOKEN_TTL_MS');
    const parsed = raw ? Number(raw) : REFRESH_TTL_MS;
    return Number.isFinite(parsed) && parsed > 0 ? parsed : REFRESH_TTL_MS;
  }
}
