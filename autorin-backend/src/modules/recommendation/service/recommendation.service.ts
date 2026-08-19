import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as dayjs from 'dayjs';
import { ContextType } from 'src/auth/interfaces';
import { COLLECTIONS } from 'src/constants';
import { POPULATIONS } from 'src/constants/populations.constants';
import { ActivityTypeEnum } from 'src/modules/activity/enums';
import { ActivityService } from 'src/modules/activity/service/activity.service';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Order } from 'src/modules/order/schema';
import { Part } from 'src/modules/part/schema';
import { RedisCacheService } from 'src/services/redis-cache/redis-cache.service';
import { TrendingService } from 'src/modules/trending/service/trending.service';
import {
  NearbyProductsArgs,
  RecommendationListArgs,
  SimilarProductsArgs,
} from '../dto/recommendation.args';
import { RecommendationScoringService } from './recommendation-scoring.service';

const CACHE_TTL = 15 * 60;

@Injectable()
export class RecommendationService {
  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.ORDERS) private readonly orderModel: Model<Order>,
    private readonly scoring: RecommendationScoringService,
    private readonly activityService: ActivityService,
    private readonly cache: RedisCacheService,
    private readonly trendingService: TrendingService,
  ) {}

  async loadPartsByIds(ids: string[]): Promise<Part[]> {
    if (!ids.length) return [];
    const objectIds = ids.map((id) => new Types.ObjectId(id));
    const parts = await this.partModel
      .find({ _id: { $in: objectIds }, status: ItemStatusEnum.ACTIVE })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .lean();

    const order = new Map(ids.map((id, i) => [id, i]));
    return [...parts].sort(
      (a, b) =>
        (order.get(a._id.toString()) ?? 0) -
        (order.get(b._id.toString()) ?? 0),
    ) as Part[];
  }

  private async fetchCandidatePool(
    limit: number,
    extraFilter: Record<string, unknown> = {},
  ) {
    return this.partModel
      .find({ status: ItemStatusEnum.ACTIVE, ...extraFilter })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .sort({ isPromoted: -1, createdAt: -1 })
      .limit(Math.min(limit * 8, 200))
      .lean();
  }

  async recommendedProducts(
    args: RecommendationListArgs,
    context: ContextType,
  ): Promise<Part[]> {
    const limit = Math.min(args.limit ?? 12, 30);
    const userId = context.userId;

    if (userId) {
      const cacheKey = this.cache.keys.recommend(userId.toString());
      const cached = await this.cache.getJson<string[]>(cacheKey);
      if (cached?.length) {
        return this.loadPartsByIds(cached.slice(0, limit));
      }
    }

    const signals = await this.scoring.buildUserSignals(userId);
    const candidates = await this.fetchCandidatePool(limit);
    const scored = await this.scoring.scoreCandidates(
      candidates as Part[],
      signals,
    );

    let result = scored.slice(0, limit).map((s) => s.part);

    if (result.length < limit) {
      const trending = await this.trendingService.getTrendingIds(
        args.city,
        limit - result.length,
      );
      const existing = new Set(result.map((p) => p._id.toString()));
      const extra = await this.loadPartsByIds(
        trending.filter((id) => !existing.has(id)),
      );
      result = [...result, ...extra].slice(0, limit);
    }

    if (userId && result.length) {
      await this.cache.setJson(
        this.cache.keys.recommend(userId.toString()),
        result.map((p) => p._id.toString()),
        CACHE_TTL,
      );
    }

    return result;
  }

  async similarProducts(args: SimilarProductsArgs): Promise<Part[]> {
    const limit = Math.min(args.limit ?? 10, 20);
    const cacheKey = this.cache.keys.similar(args.productId.toString());
    const cached = await this.cache.getJson<string[]>(cacheKey);
    if (cached?.length) {
      return this.loadPartsByIds(cached.slice(0, limit));
    }

    const source = await this.partModel
      .findById(args.productId)
      .populate(['brand', 'carModel', 'category'])
      .lean();

    if (!source) return [];

    const price = source.price ?? 0;
    const minPrice = price * 0.7;
    const maxPrice = price * 1.3;

    const candidates = await this.partModel
      .find({
        _id: { $ne: source._id },
        status: ItemStatusEnum.ACTIVE,
        $or: [
          { category: source.category },
          ...(source.brand ? [{ brand: source.brand }] : []),
          { price: { $gte: minPrice, $lte: maxPrice } },
        ],
      })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .limit(80)
      .lean();

    const signals = await this.scoring.buildUserSignals();
    const exclude = new Set([source._id.toString()]);
    const scored = await this.scoring.scoreCandidates(
      candidates as Part[],
      signals,
      exclude,
    );

    for (const c of candidates as Part[]) {
      const id = c._id.toString();
      if (exclude.has(id)) continue;
      let bonus = 0;
      if (c.category?.toString() === source.category?.toString()) bonus += 4;
      if (
        source.brand &&
        c.brand?.toString() === source.brand?.toString()
      ) {
        bonus += 5;
      }
      const p = c.price ?? 0;
      if (p >= minPrice && p <= maxPrice) bonus += 2;
      const existing = scored.find((s) => s.part._id.toString() === id);
      if (existing) existing.score += bonus;
      else if (bonus > 0) scored.push({ part: c as Part, score: bonus });
    }

    scored.sort((a, b) => b.score - a.score);
    const ids = scored.slice(0, limit).map((s) => s.part._id.toString());
    await this.cache.setJson(cacheKey, ids, CACHE_TTL);
    return this.loadPartsByIds(ids);
  }

  async nearbyProducts(
    args: NearbyProductsArgs,
    context: ContextType,
  ): Promise<Part[]> {
    const limit = Math.min(args.limit ?? 12, 30);
    const region = args.region ?? args.city ?? '';
    if (!region) {
      return this.recommendedProducts(args, context);
    }

    const parts = await this.partModel
      .find({ status: ItemStatusEnum.ACTIVE, region })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .sort({ isPromoted: -1, createdAt: -1 })
      .limit(limit)
      .lean();

    return parts as Part[];
  }

  async recentlyViewedProducts(
    args: RecommendationListArgs,
    context: ContextType,
  ): Promise<Part[]> {
    const limit = Math.min(args.limit ?? 12, 30);
    if (!context.userId) return [];

    const cacheKey = this.cache.keys.recentlyViewed(context.userId.toString());
    const cached = await this.cache.getJson<string[]>(cacheKey);
    if (cached?.length) {
      return this.loadPartsByIds(cached.slice(0, limit));
    }

    const activities = await this.activityService.getRecentByUser(
      context.userId,
      [ActivityTypeEnum.PRODUCT_VIEWED, ActivityTypeEnum.PRODUCT_OPENED],
      limit * 2,
    );

    const ids = [
      ...new Set(
        activities
          .map((a) => a.entityId?.toString())
          .filter((id): id is string => !!id),
      ),
    ].slice(0, limit);

    await this.cache.setJson(cacheKey, ids, 10 * 60);
    return this.loadPartsByIds(ids);
  }

  async recommendedOrders(
    args: RecommendationListArgs,
    context: ContextType,
  ): Promise<Order[]> {
    const limit = Math.min(args.limit ?? 12, 30);
    const signals = await this.scoring.buildUserSignals(context.userId);

    const filter: Record<string, unknown> = {
      status: 'ACTIVE',
    };

    if (signals.regions.size) {
      filter.region = { $in: [...signals.regions] };
    }

    return this.orderModel
      .find(filter)
      .populate([
        { path: 'author', model: COLLECTIONS.USERS },
        { path: 'brand', model: COLLECTIONS.CATEGORIES },
        { path: 'carModel', model: COLLECTIONS.CATEGORIES },
        { path: 'partCategory', model: COLLECTIONS.CATEGORIES },
      ])
      .sort({ isPromoted: -1, createdAt: -1 })
      .limit(limit)
      .lean() as Promise<Order[]>;
  }

  async trackProductView(
    context: ContextType,
    partId: Types.ObjectId,
    opened = false,
  ) {
    const part = await this.partModel
      .findById(partId)
      .select('brand category region price seller')
      .lean();
    if (!part) return;

    await this.activityService.track({
      userId: context.userId,
      type: opened
        ? ActivityTypeEnum.PRODUCT_OPENED
        : ActivityTypeEnum.PRODUCT_VIEWED,
      entityId: partId,
      metadata: {
        brandId: part.brand?.toString(),
        categoryId: part.category?.toString(),
        region: part.region,
        sellerId: part.seller?.toString(),
        price: part.price,
      },
    });

    if (context.userId) {
      await this.cache.del(this.cache.keys.recommend(context.userId.toString()));
      await this.cache.del(
        this.cache.keys.recentlyViewed(context.userId.toString()),
      );
    }
  }

  async trendingProducts(city?: string, limit = 12): Promise<Part[]> {
    const ids = await this.trendingService.getTrendingIds(city, limit);
    return this.loadPartsByIds(ids);
  }

  async newArrivals(limit = 12): Promise<Part[]> {
    return this.partModel
      .find({ status: ItemStatusEnum.ACTIVE })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .sort({ createdAt: -1 })
      .limit(Math.min(limit, 30))
      .lean() as Promise<Part[]>;
  }
}
