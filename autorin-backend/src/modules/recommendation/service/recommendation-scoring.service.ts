import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as dayjs from 'dayjs';
import { COLLECTIONS } from 'src/constants';
import { ActivityTypeEnum } from 'src/modules/activity/enums';
import { ActivityService } from 'src/modules/activity/service/activity.service';
import { Conversation } from 'src/modules/conversation/schema';
import { Favorite } from 'src/modules/favorite/schema';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Part } from 'src/modules/part/schema';

export type ScoredPart = { part: Part; score: number };

export type UserSignals = {
  brandIds: Set<string>;
  categoryIds: Set<string>;
  regions: Set<string>;
  favoriteSellerIds: Set<string>;
  chattedSellerIds: Set<string>;
  viewedPartIds: Set<string>;
  viewedRecentlyIds: Set<string>;
  priceAnchors: number[];
};

@Injectable()
export class RecommendationScoringService {
  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.FAVORITES)
    private readonly favoriteModel: Model<Favorite>,
    @InjectModel(COLLECTIONS.CONVERSATIONS)
    private readonly conversationModel: Model<Conversation>,
    private readonly activityService: ActivityService,
  ) {}

  async buildUserSignals(userId?: Types.ObjectId): Promise<UserSignals> {
    const signals: UserSignals = {
      brandIds: new Set(),
      categoryIds: new Set(),
      regions: new Set(),
      favoriteSellerIds: new Set(),
      chattedSellerIds: new Set(),
      viewedPartIds: new Set(),
      viewedRecentlyIds: new Set(),
      priceAnchors: [],
    };

    if (!userId) return signals;

    const profile = await this.activityService.getUserInterestProfile(userId);
    profile.brandIds.forEach((id) => signals.brandIds.add(id));
    profile.categoryIds.forEach((id) => signals.categoryIds.add(id));
    profile.regions.forEach((r) => signals.regions.add(r));
    profile.sellerIds.forEach((id) => signals.favoriteSellerIds.add(id));

    const recentCutoff = dayjs().subtract(7, 'day').toDate();
    const recentActivities = await this.activityService.getRecentByUser(
      userId,
      [
        ActivityTypeEnum.PRODUCT_VIEWED,
        ActivityTypeEnum.PRODUCT_OPENED,
      ],
      30,
    );

    for (const a of recentActivities) {
      if (!a.entityId) continue;
      const id = a.entityId.toString();
      signals.viewedPartIds.add(id);
      if (a.createdAt >= recentCutoff) {
        signals.viewedRecentlyIds.add(id);
      }
      const meta = (a.metadata ?? {}) as Record<string, unknown>;
      if (typeof meta.price === 'number') {
        signals.priceAnchors.push(meta.price);
      }
    }

    const favorite = await this.favoriteModel
      .findOne({ userId })
      .lean()
      .exec();
    if (favorite?.partsIds?.length) {
      const favParts = await this.partModel
        .find({ _id: { $in: favorite.partsIds } })
        .select('seller brand category region price')
        .lean();
      for (const p of favParts) {
        if (p.seller) signals.favoriteSellerIds.add(p.seller.toString());
        if (p.brand) signals.brandIds.add(p.brand.toString());
        if (p.category) signals.categoryIds.add(p.category.toString());
        if (p.region) signals.regions.add(p.region);
        if (p.price) signals.priceAnchors.push(p.price);
      }
    }

    const conversations = await this.conversationModel
      .find({ participants: userId })
      .select('participants')
      .lean()
      .exec();

    for (const c of conversations) {
      for (const p of c.participants ?? []) {
        const pid = p.toString();
        if (pid !== userId.toString()) {
          signals.chattedSellerIds.add(pid);
        }
      }
    }

    return signals;
  }

  scorePart(part: Part, signals: UserSignals, excludeIds = new Set<string>()): number {
    const id = part._id.toString();
    if (excludeIds.has(id)) return -1;
    if (part.status !== ItemStatusEnum.ACTIVE) return -1;

    let score = 0;

    const brandId = part.brand?.toString();
    const categoryId = part.category?.toString();
    const region = part.region ?? '';
    const sellerId = part.seller?.toString() ?? '';

    if (brandId && signals.brandIds.has(brandId)) score += 5;
    if (categoryId && signals.categoryIds.has(categoryId)) score += 4;
    if (region && signals.regions.has(region)) score += 3;

    if (sellerId && signals.favoriteSellerIds.has(sellerId)) score += 8;
    if (sellerId && signals.chattedSellerIds.has(sellerId)) score += 10;

    if (signals.viewedRecentlyIds.has(id)) score += 6;

    if (signals.priceAnchors.length && part.price) {
      const avg =
        signals.priceAnchors.reduce((a, b) => a + b, 0) /
        signals.priceAnchors.length;
      const diff = Math.abs(part.price - avg) / Math.max(avg, 1);
      if (diff <= 0.35) score += 2;
    }

    if (part.isPromoted && part.promotedUntil && part.promotedUntil > new Date()) {
      score += 7;
    }

    const ageDays = dayjs().diff(dayjs(part.createdAt), 'day');
    if (ageDays <= 7) score += 5;
    else if (ageDays <= 30) score += 2;

    return score;
  }

  async scoreCandidates(
    candidates: Part[],
    signals: UserSignals,
    excludeIds = new Set<string>(),
  ): Promise<ScoredPart[]> {
    return candidates
      .map((part) => ({
        part,
        score: this.scorePart(part, signals, excludeIds),
      }))
      .filter((s) => s.score > 0)
      .sort((a, b) => b.score - a.score);
  }
}
