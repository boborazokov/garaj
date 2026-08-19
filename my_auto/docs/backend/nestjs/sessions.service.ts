import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { createHash, randomBytes } from 'crypto';
import { Model, Types } from 'mongoose';
import { Session, SessionDocument } from './sessions.schema';

const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;

@Injectable()
export class SessionsService {
  constructor(
    @InjectModel(Session.name) private readonly sessions: Model<SessionDocument>,
  ) {}

  hashRefreshToken(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  generateRefreshToken(): string {
    return randomBytes(48).toString('base64url');
  }

  async createSession(input: {
    userId: string;
    deviceId: string;
    tokenVersion: number;
    ip?: string;
    userAgent?: string;
  }): Promise<{ sessionId: string; refreshToken: string }> {
    const refreshToken = this.generateRefreshToken();
    const doc = await this.sessions.create({
      userId: new Types.ObjectId(input.userId),
      refreshTokenHash: this.hashRefreshToken(refreshToken),
      deviceId: input.deviceId,
      tokenVersion: input.tokenVersion,
      expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
      lastUsedAt: new Date(),
      ip: input.ip,
      userAgent: input.userAgent,
    });
    return { sessionId: doc._id.toString(), refreshToken };
  }

  async rotateRefresh(refreshToken: string, deviceId: string) {
    const hash = this.hashRefreshToken(refreshToken);
    const session = await this.sessions.findOne({
      refreshTokenHash: hash,
      deviceId,
      revokedAt: null,
      expiresAt: { $gt: new Date() },
    });

    if (!session) {
      throw new UnauthorizedException({
        message: 'Invalid refresh token',
        code: 'INVALID_REFRESH_TOKEN',
      });
    }

    const newRefresh = this.generateRefreshToken();
    session.refreshTokenHash = this.hashRefreshToken(newRefresh);
    session.lastUsedAt = new Date();
    session.expiresAt = new Date(Date.now() + REFRESH_TTL_MS);
    await session.save();

    return { session, refreshToken: newRefresh };
  }

  async revokeSession(refreshToken: string, sessionId?: string) {
    const hash = this.hashRefreshToken(refreshToken);
    await this.sessions.updateOne(
      {
        refreshTokenHash: hash,
        ...(sessionId ? { _id: new Types.ObjectId(sessionId) } : {}),
      },
      { $set: { revokedAt: new Date() } },
    );
  }

  async revokeAllForUser(userId: string) {
    await this.sessions.updateMany(
      { userId: new Types.ObjectId(userId), revokedAt: null },
      { $set: { revokedAt: new Date() } },
    );
  }
}
