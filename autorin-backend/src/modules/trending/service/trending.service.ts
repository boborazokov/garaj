import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as dayjs from 'dayjs';
import { COLLECTIONS } from 'src/constants';
import { ActivityTypeEnum } from 'src/modules/activity/enums';
import { UserActivity } from 'src/modules/activity/schema/user-activity.schema';
import { Favorite } from 'src/modules/favorite/schema';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Message } from 'src/modules/message/schema';
import { Part } from 'src/modules/part/schema';
import { View } from 'src/modules/view/schema';
import { ViewTargetTypeEnum } from 'src/modules/view/enums';
import { RedisCacheService } from 'src/services/redis-cache/redis-cache.service';

export type TrendingEntry = { partId: string; score: number };

@Injectable()
export class TrendingService {
  private readonly logger = new Logger(TrendingService.name);

  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.VIEWS) private readonly viewModel: Model<View>,
    @InjectModel(COLLECTIONS.FAVORITES)
    private readonly favoriteModel: Model<Favorite>,
    @InjectModel(COLLECTIONS.MESSAGES)
    private readonly messageModel: Model<Message>,
    @InjectModel(COLLECTIONS.USER_ACTIVITIES)
    private readonly activityModel: Model<UserActivity>,
    private readonly cache: RedisCacheService,
  ) {}

  async recalculateTrending() {
    const since = dayjs().subtract(7, 'day').toDate();
    const scoreMap = new Map<string, number>();

    const bump = (partId: string, points: number) => {
      scoreMap.set(partId, (scoreMap.get(partId) ?? 0) + points);
    };

    const views = await this.viewModel
      .aggregate<{ _id: Types.ObjectId; count: number }>([
        {
          $match: {
            targetType: ViewTargetTypeEnum.PART,
            createdAt: { $gte: since },
          },
        },
        { $group: { _id: '$targetId', count: { $sum: 1 } } },
      ]);

    for (const v of views) {
      bump(v._id.toString(), v.count * 3);
    }

    const favorites = await this.favoriteModel.find().lean();
    for (const fav of favorites) {
      for (const partId of fav.partsIds ?? []) {
        bump(partId.toString(), 5);
      }
    }

    const recentMessages = await this.messageModel
      .aggregate<{ _id: Types.ObjectId; count: number }>([
        { $match: { createdAt: { $gte: since } } },
        {
          $lookup: {
            from: COLLECTIONS.CONVERSATIONS,
            localField: 'conversation',
            foreignField: '_id',
            as: 'conv',
          },
        },
        { $unwind: '$conv' },
        { $group: { _id: '$conv.part', count: { $sum: 1 } } },
        { $match: { _id: { $ne: null } } },
      ]);

    for (const m of recentMessages) {
      if (m._id) bump(m._id.toString(), m.count * 4);
    }

    const activities = await this.activityModel
      .aggregate<{ _id: Types.ObjectId; count: number }>([
        {
          $match: {
            type: {
              $in: [
                ActivityTypeEnum.PRODUCT_VIEWED,
                ActivityTypeEnum.PRODUCT_OPENED,
              ],
            },
            entityId: { $ne: null },
            createdAt: { $gte: since },
          },
        },
        { $group: { _id: '$entityId', count: { $sum: 1 } } },
      ]);

    for (const a of activities) {
      if (a._id) bump(a._id.toString(), a.count * 6);
    }

    const activeParts = await this.partModel
      .find({ status: ItemStatusEnum.ACTIVE })
      .select('_id region isPromoted promotedUntil createdAt')
      .lean();

    const activeSet = new Set(activeParts.map((p) => p._id.toString()));
    const regionBuckets = new Map<string, TrendingEntry[]>();

    const globalSorted: TrendingEntry[] = [...scoreMap.entries()]
      .filter(([id]) => activeSet.has(id))
      .map(([partId, score]) => {
        const part = activeParts.find((p) => p._id.toString() === partId);
        let finalScore = score;
        if (
          part?.isPromoted &&
          part.promotedUntil &&
          part.promotedUntil > new Date()
        ) {
          finalScore += 7;
        }
        const ageDays = dayjs().diff(dayjs(part?.createdAt), 'day');
        if (ageDays <= 3) finalScore += 5;

        if (part?.region) {
          const bucket = regionBuckets.get(part.region) ?? [];
          bucket.push({ partId, score: finalScore });
          regionBuckets.set(part.region, bucket);
        }

        return { partId, score: finalScore };
      })
      .sort((a, b) => b.score - a.score)
      .slice(0, 100);

    await this.cache.setJson(
      this.cache.keys.trendingGlobal(),
      globalSorted.map((e) => e.partId),
      60 * 60,
    );

    for (const [city, entries] of regionBuckets) {
      const sorted = entries.sort((a, b) => b.score - a.score).slice(0, 50);
      await this.cache.setJson(
        this.cache.keys.trendingCity(city),
        sorted.map((e) => e.partId),
        60 * 60,
      );
    }

    this.logger.log(
      `Trending recalculated: global=${globalSorted.length}, cities=${regionBuckets.size}`,
    );
  }

  async getTrendingIds(city?: string, limit = 12): Promise<string[]> {
    const key = city
      ? this.cache.keys.trendingCity(city)
      : this.cache.keys.trendingGlobal();
    const cached = await this.cache.getJson<string[]>(key);
    if (cached?.length) return cached.slice(0, limit);

    const parts = await this.partModel
      .find({ status: ItemStatusEnum.ACTIVE, ...(city ? { region: city } : {}) })
      .sort({ isPromoted: -1, createdAt: -1 })
      .limit(limit)
      .select('_id')
      .lean();

    return parts.map((p) => p._id.toString());
  }

  async trendingProducts(city?: string, limit = 12): Promise<string[]> {
    return this.getTrendingIds(city, limit);
  }
}
