import { BadRequestException, Injectable } from '@nestjs/common';
import { ViewTargetTypeEnum } from '../enums';
import { Model, Types } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { View } from '../schema';
import { GetTargetViewsCountArgs, ViewsTargetInput } from '../dto';

@Injectable()
export class ViewService {
  constructor(
    @InjectModel(COLLECTIONS.VIEWS) private readonly viewModel: Model<View>,
  ) {}

  async getViewsCount(
    targetType: ViewTargetTypeEnum,
    targetId: Types.ObjectId,
  ) {
    return this.viewModel.countDocuments({
      targetType,
      targetId,
    });
  }

  /**
   * Records at most one view per device per listing.
   * @returns true when this was a new unique device view.
   */
  async recordUniqueDeviceView(params: {
    targetType: ViewTargetTypeEnum;
    targetId: Types.ObjectId;
    deviceId: string;
    userId?: Types.ObjectId | null;
  }): Promise<boolean> {
    const deviceId = params.deviceId.trim();
    if (!deviceId) return false;

    try {
      const result = await this.viewModel.updateOne(
        {
          targetType: params.targetType,
          targetId: params.targetId,
          deviceId,
        },
        {
          $setOnInsert: {
            targetType: params.targetType,
            targetId: params.targetId,
            deviceId,
            userId: params.userId ?? null,
          },
        },
        { upsert: true },
      );
      return (result.upsertedCount ?? 0) > 0;
    } catch {
      // Duplicate key race — already counted for this device.
      return false;
    }
  }

  /** @deprecated Prefer recordUniqueDeviceView (device-scoped). */
  async incrementViewsCount(
    targetType: ViewTargetTypeEnum,
    targetId: Types.ObjectId,
    userId: Types.ObjectId,
  ) {
    const existingView = await this.viewModel.findOne({
      targetType,
      targetId,
      userId,
    });

    if (!existingView) {
      await this.viewModel.create({
        targetType,
        targetId,
        userId,
        deviceId: `user:${userId.toString()}`,
      });
      return true;
    }

    return false;
  }

  parseTarget(target: ViewsTargetInput) {
    const { partId } = target;

    if (partId) {
      return {
        _id: partId,
        type: ViewTargetTypeEnum.PART,
      };
    }

    throw new BadRequestException('Invalid target');
  }

  async getTargetViewsCount({ target }: GetTargetViewsCountArgs) {
    const { _id: partId, type } = this.parseTarget(target);
    return this.getViewsCount(type, partId);
  }
}
