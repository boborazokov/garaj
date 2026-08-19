import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { ActivityTypeEnum } from '../enums';
import { UserActivity } from '../schema';
import { AnalyticsService } from 'src/modules/analytics/service/analytics.service';

export type TrackActivityInput = {
  userId?: Types.ObjectId;
  type: ActivityTypeEnum;
  entityId?: Types.ObjectId;
  metadata?: Record<string, unknown>;
};

@Injectable()
export class ActivityService {
  constructor(
    @InjectModel(COLLECTIONS.USER_ACTIVITIES)
    private readonly activityModel: Model<UserActivity>,
    private readonly analyticsService: AnalyticsService,
  ) {}

  async track(input: TrackActivityInput) {
    await this.activityModel.create({
      userId: input.userId,
      type: input.type,
      entityId: input.entityId,
      metadata: input.metadata ?? {},
    });
    if (input.userId) {
      void this.analyticsService.recordVisit(input.userId);
    }
  }

  async getRecentByUser(
    userId: Types.ObjectId,
    types: ActivityTypeEnum[],
    limit = 50,
  ) {
    return this.activityModel
      .find({ userId, type: { $in: types } })
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean()
      .exec();
  }

  async getUserInterestProfile(userId: Types.ObjectId) {
    const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const activities = await this.activityModel
      .find({
        userId,
        createdAt: { $gte: since },
        type: {
          $in: [
            ActivityTypeEnum.PRODUCT_VIEWED,
            ActivityTypeEnum.PRODUCT_OPENED,
            ActivityTypeEnum.FAVORITE_ADDED,
            ActivityTypeEnum.SEARCH_QUERY,
          ],
        },
      })
      .sort({ createdAt: -1 })
      .limit(200)
      .lean()
      .exec();

    const viewedPartIds: Types.ObjectId[] = [];
    const favoritePartIds: Types.ObjectId[] = [];
    const searchQueries: string[] = [];
    const brandIds = new Set<string>();
    const categoryIds = new Set<string>();
    const regions = new Set<string>();
    const sellerIds = new Set<string>();

    for (const a of activities) {
      const meta = (a.metadata ?? {}) as Record<string, string>;
      if (meta.brandId) brandIds.add(meta.brandId);
      if (meta.categoryId) categoryIds.add(meta.categoryId);
      if (meta.region) regions.add(meta.region);
      if (meta.sellerId) sellerIds.add(meta.sellerId);

      if (
        a.type === ActivityTypeEnum.PRODUCT_VIEWED ||
        a.type === ActivityTypeEnum.PRODUCT_OPENED
      ) {
        if (a.entityId) viewedPartIds.push(a.entityId);
      }
      if (a.type === ActivityTypeEnum.FAVORITE_ADDED && a.entityId) {
        favoritePartIds.push(a.entityId);
      }
      if (a.type === ActivityTypeEnum.SEARCH_QUERY && meta.query) {
        searchQueries.push(meta.query);
      }
    }

    return {
      viewedPartIds,
      favoritePartIds,
      searchQueries,
      brandIds: [...brandIds],
      categoryIds: [...categoryIds],
      regions: [...regions],
      sellerIds: [...sellerIds],
    };
  }
}
