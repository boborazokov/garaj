import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { RegisterDeviceTokenInput } from '../dto';
import { DeviceToken } from '../schema';

@Injectable()
export class DeviceTokenService {
  private readonly logger = new Logger(DeviceTokenService.name);

  constructor(
    @InjectModel(COLLECTIONS.DEVICE_TOKENS)
    private readonly deviceTokenModel: Model<DeviceToken>,
  ) {}

  /**
   * Idempotent upsert on `token`. Allows the same physical device to
   * "move" between user accounts (e.g. user logs out and a different
   * account logs in on the same phone) without leaking unread badges
   * to the previous owner.
   */
  async register(
    userId: Types.ObjectId,
    input: RegisterDeviceTokenInput,
  ): Promise<DeviceToken> {
    const updated = await this.deviceTokenModel.findOneAndUpdate(
      { token: input.token },
      {
        $set: {
          user: userId,
          platform: input.platform,
          locale: input.locale ?? '',
          appVersion: input.appVersion ?? '',
          deviceModel: input.deviceModel ?? '',
          isActive: true,
          lastSeenAt: new Date(),
        },
      },
      { upsert: true, new: true, setDefaultsOnInsert: true },
    );
    return updated;
  }

  /** Used on logout. Marks the row inactive (history preserved). */
  async remove(userId: Types.ObjectId, token: string): Promise<boolean> {
    const res = await this.deviceTokenModel.updateOne(
      { token, user: userId },
      { $set: { isActive: false } },
    );
    return res.modifiedCount > 0;
  }

  /** Logout when JWT is already cleared or expired (token-only). */
  async deactivateByToken(token: string): Promise<boolean> {
    const res = await this.deviceTokenModel.updateOne(
      { token },
      { $set: { isActive: false } },
    );
    return res.modifiedCount > 0;
  }

  /**
   * Marks a list of tokens inactive in one round-trip. Called by the
   * push worker when FCM responds with
   *  `messaging/registration-token-not-registered`
   *  or `messaging/invalid-registration-token`.
   */
  async deactivateMany(tokens: string[]): Promise<void> {
    if (!tokens.length) return;
    await this.deviceTokenModel.updateMany(
      { token: { $in: tokens } },
      { $set: { isActive: false } },
    );
    this.logger.warn(`Deactivated ${tokens.length} invalid device tokens.`);
  }

  /** All live tokens for a set of users. Tight projection to keep payloads small. */
  async activeTokensForUsers(userIds: Types.ObjectId[]): Promise<string[]> {
    if (!userIds.length) return [];
    const rows = await this.deviceTokenModel
      .find({ user: { $in: userIds }, isActive: true })
      .select('token')
      .lean();
    return rows.map((r) => r.token);
  }
}
