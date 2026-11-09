import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, PaginateModel, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { Advertisement } from '../schema';
import { AdvertisementInput } from '../dto/inputs/advertisement.input';
import { AdminListAdvertisementsArgs } from '../dto/args/admin-list-advertisements.args';
import { GetAdvertisementsArgs } from '../dto/args/get-advertisements.args';
import { PaginatedAdvertisements } from '../types/paginated-advertisements.type';
import { AdvertisementStatusEnum } from '../enums';

@Injectable()
export class AdvertisementService {
  constructor(
    @InjectModel(COLLECTIONS.ADVERTISEMENTS)
    private advertisementModel: PaginateModel<Advertisement>,
  ) {}

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
   * Public banner feed consumed by the mobile app. Only ACTIVE campaigns inside
   * their date window are returned. Sorted newest first so a fresh campaign
   * leads the rotation pool.
   */
  async listPublic(args: GetAdvertisementsArgs): Promise<Advertisement[]> {
    const now = new Date();
    const query: FilterQuery<Advertisement> = {
      status: { $ne: AdvertisementStatusEnum.PAUSED },
      $and: [
        {
          $or: [{ startsAt: null }, { startsAt: { $exists: false } }, { startsAt: { $lte: now } }],
        },
        {
          $or: [{ endsAt: null }, { endsAt: { $exists: false } }, { endsAt: { $gte: now } }],
        },
      ],
    };
    if (args.filter?.type) query.type = args.filter.type;

    const docs = await this.advertisementModel
      .find(query)
      .sort({ createdAt: -1 })
      .limit(20)
      .lean<Advertisement[]>();

    return docs.map((doc) => this.withComputed(doc));
  }

  async create(data: AdvertisementInput): Promise<Advertisement> {
    this.assertBannerImageRef(data.bannerImageUrl, 'bannerImageUrl');
    this.assertLinkRef(data.link, 'link');
    this.assertDateWindow(data.startsAt, data.endsAt);
    this.assertWritableStatus(data.status);
    await this.assertNoDuplicate(data);

    const created = await this.advertisementModel.create({
      type: data.type,
      bannerImageUrl: data.bannerImageUrl.trim(),
      title: data.title.trim(),
      link: data.link.trim(),
      startsAt: data.startsAt ?? null,
      endsAt: data.endsAt ?? null,
      status: data.status ?? AdvertisementStatusEnum.ACTIVE,
      isFree: Boolean(data.isFree),
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

    const $set: Record<string, unknown> = {
      type: data.type,
      bannerImageUrl: data.bannerImageUrl.trim(),
      title: data.title.trim(),
      link: data.link.trim(),
      startsAt: data.startsAt ?? null,
      endsAt: data.endsAt ?? null,
      isFree: Boolean(data.isFree),
    };
    if (data.status) {
      $set.status = data.status;
    }

    const updated = await this.advertisementModel
      .findByIdAndUpdate(advertisementId, { $set }, { new: true })
      .lean<Advertisement>();
    if (!updated) throw new BadRequestException('Advertisement not found');
    return this.withComputed(updated);
  }

  async delete(advertisementId: Types.ObjectId): Promise<boolean> {
    const res = await this.advertisementModel.deleteOne({ _id: advertisementId });
    if (res.deletedCount === 0) {
      throw new BadRequestException('Advertisement not found');
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
    } else if (filter?.status === AdvertisementStatusEnum.PAUSED) {
      query.status = AdvertisementStatusEnum.PAUSED;
      query.$or = [
        { endsAt: null },
        { endsAt: { $exists: false } },
        { endsAt: { $gte: new Date() } },
      ];
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
      status: this.effectiveStatus(ad),
      ctr: this.computeCtr(impressionCount, clickCount),
    };
  }

  private effectiveStatus(ad: Advertisement): AdvertisementStatusEnum {
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

  /**
   * Upload returns a MinIO storage key (`bucket/catalog/file.ext`), not a full
   * URL — accept both that and absolute http(s) links.
   */
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

  /** Tap target: https URL, deep link, or in-app route. */
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
