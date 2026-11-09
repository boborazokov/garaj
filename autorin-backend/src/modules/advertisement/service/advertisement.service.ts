import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, PaginateModel, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { CurrencyEnum } from 'src/shared/enums/currency.enum';
import { WalletService } from 'src/modules/wallet/service';
import {
  advertisementTariffKey,
  AppSettingsService,
} from 'src/modules/app-settings/service';
import {
  ADVERTISEMENT_PLAN_PRICES_UZS,
  ADVERTISEMENT_PLACEMENT_WEIGHT,
} from '../constants/plan-prices';
import { ADVERTISEMENT_MAX_ACTIVE_SLOTS } from '../constants/slot-limits';
import {
  Advertisement,
  AdvertisementPlanPrice,
  AdvertisementSlotInfo,
} from '../schema';
import { AdvertisementInput } from '../dto/inputs/advertisement.input';
import { AdminListAdvertisementsArgs } from '../dto/args/admin-list-advertisements.args';
import { GetAdvertisementsArgs } from '../dto/args/get-advertisements.args';
import { PurchaseAdvertisementArgs } from '../dto/args/purchase-advertisement.args';
import { PaginatedAdvertisements } from '../types/paginated-advertisements.type';
import {
  AdvertisementPlanEnum,
  AdvertisementStatusEnum,
  ADVERTISEMENT_PLAN_DAYS,
  ADVERTISEMENT_PLAN_WEIGHT,
} from '../enums';

@Injectable()
export class AdvertisementService {
  constructor(
    @InjectModel(COLLECTIONS.ADVERTISEMENTS)
    private advertisementModel: PaginateModel<Advertisement>,
    private readonly walletService: WalletService,
    private readonly appSettingsService: AppSettingsService,
  ) {}

  /** Public catalog of banner tariffs (placement × duration). */
  async getPlanPrices(): Promise<AdvertisementPlanPrice[]> {
    const overrides = await this.appSettingsService.getAdvertisementTariffs();
    const placements = Object.values(CategoryTypeEnum).sort(
      (a, b) =>
        (ADVERTISEMENT_PLACEMENT_WEIGHT[b] ?? 0) -
        (ADVERTISEMENT_PLACEMENT_WEIGHT[a] ?? 0),
    );
    const plans = Object.values(AdvertisementPlanEnum).sort(
      (a, b) => ADVERTISEMENT_PLAN_WEIGHT[a] - ADVERTISEMENT_PLAN_WEIGHT[b],
    );

    const rows: AdvertisementPlanPrice[] = [];
    for (const placement of placements) {
      for (const plan of plans) {
        const key = advertisementTariffKey(placement, plan);
        const fallback = ADVERTISEMENT_PLAN_PRICES_UZS[placement][plan];
        const amount =
          typeof overrides[key] === 'number' ? overrides[key] : fallback;
        rows.push({
          placement,
          plan,
          amount,
          currency: CurrencyEnum.UZS,
          days: ADVERTISEMENT_PLAN_DAYS[plan],
          priority:
            (ADVERTISEMENT_PLACEMENT_WEIGHT[placement] ?? 0) * 10 +
            ADVERTISEMENT_PLAN_WEIGHT[plan],
        });
      }
    }
    return rows;
  }

  async priceForPlan(
    placement: CategoryTypeEnum,
    plan: AdvertisementPlanEnum,
  ): Promise<number> {
    const overrides = await this.appSettingsService.getAdvertisementTariffs();
    const key = advertisementTariffKey(placement, plan);
    const amount =
      typeof overrides[key] === 'number'
        ? overrides[key]
        : ADVERTISEMENT_PLAN_PRICES_UZS[placement]?.[plan];
    if (amount == null || amount < 0) {
      throw new BadRequestException('Unknown advertisement tariff');
    }
    return amount;
  }

  async slotInfo(type: CategoryTypeEnum): Promise<AdvertisementSlotInfo> {
    await this.promoteQueued(type);
    const activeCount = await this.countLiveSlots(type);
    const queueLength = await this.advertisementModel.countDocuments({
      type,
      status: AdvertisementStatusEnum.QUEUED,
    });
    return {
      placement: type,
      activeCount,
      maxSlots: ADVERTISEMENT_MAX_ACTIVE_SLOTS,
      queueLength,
      hasFreeSlot: activeCount < ADVERTISEMENT_MAX_ACTIVE_SLOTS,
    };
  }

  async list(args: AdminListAdvertisementsArgs): Promise<PaginatedAdvertisements> {
    const { pagination, filter } = args;
    const query = this.buildAdminQuery(filter);

    const { docs, ...meta } = await this.advertisementModel.paginate(query, {
      ...pagination,
      sort: { createdAt: -1 },
      lean: true,
    });

    return {
      payload: docs.map((doc) => this.withComputed(doc)),
      ...meta,
    };
  }

  /**
   * Public banner feed. Only live ACTIVE campaigns. Cap = slot limit.
   * Promotes queued banners when a slot frees up.
   */
  async listPublic(args: GetAdvertisementsArgs): Promise<Advertisement[]> {
    const type = args.filter?.type;
    if (type) {
      await this.promoteQueued(type);
    }

    const now = new Date();
    const query: FilterQuery<Advertisement> = {
      status: AdvertisementStatusEnum.ACTIVE,
      $and: [
        {
          $or: [
            { startsAt: null },
            { startsAt: { $exists: false } },
            { startsAt: { $lte: now } },
          ],
        },
        {
          $or: [
            { endsAt: null },
            { endsAt: { $exists: false } },
            { endsAt: { $gte: now } },
          ],
        },
      ],
    };
    if (type) query.type = type;

    const docs = await this.advertisementModel
      .find(query)
      .sort({ createdAt: -1 })
      .limit(ADVERTISEMENT_MAX_ACTIVE_SLOTS)
      .lean<Advertisement[]>();

    return docs.map((doc) => this.withComputed(doc));
  }

  async listMine(context: ContextType): Promise<Advertisement[]> {
    const { userId } = assertAuthenticated(context);
    const docs = await this.advertisementModel
      .find({ ownerId: new Types.ObjectId(userId) })
      .sort({ createdAt: -1 })
      .limit(100)
      .lean<Advertisement[]>();
    return docs.map((doc) => this.withComputed(doc));
  }

  /**
   * User buys a banner: upload key already stored → wallet debit → live or queue.
   */
  async purchase(
    args: PurchaseAdvertisementArgs,
    context: ContextType,
  ): Promise<Advertisement> {
    const { userId } = assertAuthenticated(context);
    const ownerId = new Types.ObjectId(userId);
    const title = args.title?.trim() ?? '';
    const link = args.link?.trim() ?? '';
    const bannerImageUrl = args.bannerImageUrl?.trim() ?? '';

    if (!title) throw new BadRequestException('title is required');
    this.assertBannerImageRef(bannerImageUrl, 'bannerImageUrl');
    this.assertLinkRef(link, 'link');

    const amount = await this.priceForPlan(args.type, args.plan);
    const days = ADVERTISEMENT_PLAN_DAYS[args.plan];
    await this.promoteQueued(args.type);

    const live = await this.countLiveSlots(args.type);
    const goLive = live < ADVERTISEMENT_MAX_ACTIVE_SLOTS;
    const now = new Date();
    const endsAt = goLive
      ? new Date(now.getTime() + days * 86_400_000)
      : null;
    const queuePosition = goLive
      ? 0
      : (await this.nextQueuePosition(args.type));

    const created = await this.advertisementModel.create({
      type: args.type,
      bannerImageUrl,
      title,
      link,
      startsAt: goLive ? now : null,
      endsAt,
      status: goLive
        ? AdvertisementStatusEnum.ACTIVE
        : AdvertisementStatusEnum.QUEUED,
      isFree: false,
      ownerId,
      plan: args.plan,
      amountPaid: amount,
      queuePosition,
      impressionCount: 0,
      clickCount: 0,
    });

    try {
      await this.walletService.debitForAdvertisement({
        userId: ownerId,
        amount,
        advertisementId: created._id as Types.ObjectId,
        plan: args.plan,
        placement: args.type,
      });
    } catch (err) {
      await this.advertisementModel.deleteOne({ _id: created._id });
      throw err;
    }

    return this.withComputed(created.toObject());
  }

  /** Owner pauses a live campaign — frees a slot for the queue. */
  async pauseMine(
    advertisementId: Types.ObjectId,
    context: ContextType,
  ): Promise<Advertisement> {
    const { userId } = assertAuthenticated(context);
    const ad = await this.advertisementModel.findById(advertisementId);
    if (!ad) throw new BadRequestException('Advertisement not found');
    if (!ad.ownerId || ad.ownerId.toString() !== userId.toString()) {
      throw new ForbiddenException('Not your advertisement');
    }
    if (ad.status === AdvertisementStatusEnum.QUEUED) {
      throw new BadRequestException('Queued ads cannot be paused — delete instead');
    }
    ad.status = AdvertisementStatusEnum.PAUSED;
    ad.queuePosition = 0;
    await ad.save();
    await this.promoteQueued(ad.type);
    return this.withComputed(ad.toObject());
  }

  async create(data: AdvertisementInput): Promise<Advertisement> {
    this.assertBannerImageRef(data.bannerImageUrl, 'bannerImageUrl');
    this.assertLinkRef(data.link, 'link');
    this.assertDateWindow(data.startsAt, data.endsAt);
    this.assertWritableStatus(data.status);
    await this.assertNoDuplicate(data);

    const isFree = Boolean(data.isFree);
    const plan = data.plan ?? null;
    const amountPaid = isFree
      ? 0
      : await this.resolveAmountPaid(data.type, plan, data.amountPaid);

    const created = await this.advertisementModel.create({
      type: data.type,
      bannerImageUrl: data.bannerImageUrl.trim(),
      title: data.title.trim(),
      link: data.link.trim(),
      startsAt: data.startsAt ?? null,
      endsAt: data.endsAt ?? null,
      status: data.status ?? AdvertisementStatusEnum.ACTIVE,
      isFree,
      ownerId: null,
      plan,
      amountPaid,
      queuePosition: 0,
      impressionCount: 0,
      clickCount: 0,
    });

    return this.withComputed(created.toObject());
  }

  async update(
    advertisementId: Types.ObjectId,
    data: AdvertisementInput,
  ): Promise<Advertisement> {
    this.assertBannerImageRef(data.bannerImageUrl, 'bannerImageUrl');
    this.assertLinkRef(data.link, 'link');
    this.assertDateWindow(data.startsAt, data.endsAt);
    this.assertWritableStatus(data.status);
    await this.assertNoDuplicate(data, advertisementId);

    const isFree = Boolean(data.isFree);
    const plan = data.plan ?? null;
    const amountPaid = isFree
      ? 0
      : await this.resolveAmountPaid(data.type, plan, data.amountPaid);

    const $set: Record<string, unknown> = {
      type: data.type,
      bannerImageUrl: data.bannerImageUrl.trim(),
      title: data.title.trim(),
      link: data.link.trim(),
      startsAt: data.startsAt ?? null,
      endsAt: data.endsAt ?? null,
      isFree,
      plan,
      amountPaid,
    };
    if (data.status) {
      $set.status = data.status;
    }

    const updated = await this.advertisementModel
      .findByIdAndUpdate(advertisementId, { $set }, { new: true })
      .lean<Advertisement>();
    if (!updated) throw new BadRequestException('Advertisement not found');
    if (data.status === AdvertisementStatusEnum.PAUSED) {
      await this.promoteQueued(data.type);
    }
    return this.withComputed(updated);
  }

  private async resolveAmountPaid(
    type: CategoryTypeEnum,
    plan: AdvertisementPlanEnum | null | undefined,
    override?: number | null,
  ): Promise<number> {
    if (typeof override === 'number' && override >= 0) {
      return Math.floor(override);
    }
    if (!plan) return 0;
    return this.priceForPlan(type, plan);
  }

  async delete(advertisementId: Types.ObjectId): Promise<boolean> {
    const existing = await this.advertisementModel
      .findById(advertisementId)
      .lean<Advertisement>();
    const res = await this.advertisementModel.deleteOne({ _id: advertisementId });
    if (res.deletedCount === 0) {
      throw new BadRequestException('Advertisement not found');
    }
    if (existing?.type) {
      await this.promoteQueued(existing.type);
    }
    return true;
  }

  async recordImpression(advertisementId: Types.ObjectId): Promise<Advertisement> {
    const updated = await this.advertisementModel
      .findByIdAndUpdate(
        advertisementId,
        { $inc: { impressionCount: 1 } },
        { new: true },
      )
      .lean<Advertisement>();
    if (!updated) throw new BadRequestException('Advertisement not found');
    return this.withComputed(updated);
  }

  async recordClick(advertisementId: Types.ObjectId): Promise<Advertisement> {
    const updated = await this.advertisementModel
      .findByIdAndUpdate(
        advertisementId,
        { $inc: { clickCount: 1 } },
        { new: true },
      )
      .lean<Advertisement>();
    if (!updated) throw new BadRequestException('Advertisement not found');
    return this.withComputed(updated);
  }

  /** Fill free live slots from the queue (FIFO). */
  async promoteQueued(type: CategoryTypeEnum): Promise<void> {
    for (let i = 0; i < ADVERTISEMENT_MAX_ACTIVE_SLOTS; i++) {
      const live = await this.countLiveSlots(type);
      if (live >= ADVERTISEMENT_MAX_ACTIVE_SLOTS) return;

      const next = await this.advertisementModel
        .findOne({ type, status: AdvertisementStatusEnum.QUEUED })
        .sort({ queuePosition: 1, createdAt: 1 });
      if (!next) return;

      const days = next.plan
        ? ADVERTISEMENT_PLAN_DAYS[next.plan]
        : ADVERTISEMENT_PLAN_DAYS[AdvertisementPlanEnum.WEEK];
      const now = new Date();
      next.status = AdvertisementStatusEnum.ACTIVE;
      next.queuePosition = 0;
      next.startsAt = now;
      next.endsAt = new Date(now.getTime() + days * 86_400_000);
      await next.save();
    }
  }

  private async countLiveSlots(type: CategoryTypeEnum): Promise<number> {
    const now = new Date();
    return this.advertisementModel.countDocuments({
      type,
      status: AdvertisementStatusEnum.ACTIVE,
      $and: [
        {
          $or: [
            { startsAt: null },
            { startsAt: { $exists: false } },
            { startsAt: { $lte: now } },
          ],
        },
        {
          $or: [
            { endsAt: null },
            { endsAt: { $exists: false } },
            { endsAt: { $gte: now } },
          ],
        },
      ],
    });
  }

  private async nextQueuePosition(type: CategoryTypeEnum): Promise<number> {
    const last = await this.advertisementModel
      .findOne({ type, status: AdvertisementStatusEnum.QUEUED })
      .sort({ queuePosition: -1 })
      .lean();
    return (last?.queuePosition ?? 0) + 1;
  }

  private buildAdminQuery(
    filter?: AdminListAdvertisementsArgs['filter'],
  ): FilterQuery<Advertisement> {
    const query: FilterQuery<Advertisement> = {};
    if (filter?.type) query.type = filter.type;
    if (typeof filter?.isFree === 'boolean') query.isFree = filter.isFree;
    if (filter?.title?.trim()) {
      query.title = { $regex: filter.title.trim(), $options: 'i' };
    }

    if (filter?.status === AdvertisementStatusEnum.EXPIRED) {
      query.endsAt = { $ne: null, $lt: new Date() };
      query.status = { $ne: AdvertisementStatusEnum.QUEUED };
    } else if (filter?.status === AdvertisementStatusEnum.PAUSED) {
      query.status = AdvertisementStatusEnum.PAUSED;
      query.$or = [
        { endsAt: null },
        { endsAt: { $exists: false } },
        { endsAt: { $gte: new Date() } },
      ];
    } else if (filter?.status === AdvertisementStatusEnum.QUEUED) {
      query.status = AdvertisementStatusEnum.QUEUED;
    } else if (filter?.status === AdvertisementStatusEnum.ACTIVE) {
      query.status = AdvertisementStatusEnum.ACTIVE;
      query.$and = [
        {
          $or: [
            { endsAt: null },
            { endsAt: { $exists: false } },
            { endsAt: { $gte: new Date() } },
          ],
        },
      ];
    }

    return query;
  }

  private withComputed(doc: Advertisement | Record<string, unknown>): Advertisement {
    const ad = doc as Advertisement;
    const impressionCount = Number(ad.impressionCount) || 0;
    const clickCount = Number(ad.clickCount) || 0;
    return {
      ...ad,
      impressionCount,
      clickCount,
      isFree: Boolean(ad.isFree),
      amountPaid: Number(ad.amountPaid) || 0,
      queuePosition: Number(ad.queuePosition) || 0,
      status: this.effectiveStatus(ad),
      ctr: this.computeCtr(impressionCount, clickCount),
    };
  }

  private effectiveStatus(ad: Advertisement): AdvertisementStatusEnum {
    if (ad.status === AdvertisementStatusEnum.QUEUED) {
      return AdvertisementStatusEnum.QUEUED;
    }
    if (ad.endsAt && new Date(ad.endsAt).getTime() < Date.now()) {
      return AdvertisementStatusEnum.EXPIRED;
    }
    if (ad.status === AdvertisementStatusEnum.PAUSED) {
      return AdvertisementStatusEnum.PAUSED;
    }
    return AdvertisementStatusEnum.ACTIVE;
  }

  private computeCtr(impressions: number, clicks: number) {
    if (!impressions || impressions <= 0) return 0;
    return Math.round((clicks / impressions) * 10000) / 100;
  }

  private assertWritableStatus(status?: AdvertisementStatusEnum | null) {
    if (!status) return;
    if (
      status !== AdvertisementStatusEnum.ACTIVE &&
      status !== AdvertisementStatusEnum.PAUSED
    ) {
      throw new BadRequestException('status must be ACTIVE or PAUSED');
    }
  }

  private assertDateWindow(startsAt?: Date | null, endsAt?: Date | null) {
    if (startsAt && endsAt && new Date(startsAt).getTime() > new Date(endsAt).getTime()) {
      throw new BadRequestException('startsAt must be before endsAt');
    }
  }

  private assertBannerImageRef(value: string, field: string) {
    const v = value?.trim() ?? '';
    if (!v) {
      throw new BadRequestException(`${field} is required`);
    }
    try {
      const parsed = new URL(v);
      if (parsed.protocol === 'https:' || parsed.protocol === 'http:') {
        return;
      }
    } catch {
      /* relative storage path */
    }
    if (/^[\w./-]+$/.test(v) && v.includes('/')) {
      return;
    }
    throw new BadRequestException(
      `${field} must be a valid URL or uploaded storage path`,
    );
  }

  private assertLinkRef(value: string, field: string) {
    const v = value?.trim() ?? '';
    if (!v) {
      throw new BadRequestException(`${field} is required`);
    }
    if (v.startsWith('/')) return;
    try {
      const parsed = new URL(v.includes('://') ? v : `https://${v}`);
      if (
        parsed.protocol === 'https:' ||
        parsed.protocol === 'http:' ||
        parsed.protocol === 'autorin:'
      ) {
        return;
      }
    } catch {
      /* fall through */
    }
    throw new BadRequestException(
      `${field} must be https://…, autorin://… or /in-app-route`,
    );
  }

  private async assertNoDuplicate(
    data: AdvertisementInput,
    excludeId?: Types.ObjectId,
  ) {
    const query: FilterQuery<Advertisement> = {
      type: data.type,
      $or: [
        { bannerImageUrl: data.bannerImageUrl.trim() },
        { link: data.link.trim() },
      ],
    };
    if (excludeId) query._id = { $ne: excludeId };

    const found = await this.advertisementModel.findOne(query).lean();
    if (found) {
      throw new BadRequestException(
        'Advertisement with this banner or link already exists for this type',
      );
    }
  }
}
