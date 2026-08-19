import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, PaginateModel, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { Advertisement } from '../schema';
import { AdvertisementInput } from '../dto/inputs/advertisement.input';
import { AdminListAdvertisementsArgs } from '../dto/args/admin-list-advertisements.args';
import { GetAdvertisementsArgs } from '../dto/args/get-advertisements.args';
import { PaginatedAdvertisements } from '../types/paginated-advertisements.type';

@Injectable()
export class AdvertisementService {
  constructor(
    @InjectModel(COLLECTIONS.ADVERTISEMENTS)
    private advertisementModel: PaginateModel<Advertisement>,
  ) {}

  async list(args: AdminListAdvertisementsArgs): Promise<PaginatedAdvertisements> {
    const { pagination, filter } = args;
    const query: FilterQuery<Advertisement> = {};
    if (filter?.type) query.type = filter.type;

    const { docs, ...meta } = await this.advertisementModel.paginate(query, {
      ...pagination,
      sort: { createdAt: -1 },
    });

    return { payload: docs, ...meta };
  }

  /**
   * Public banner feed consumed by the mobile app. Capped to a sane number to
   * keep payloads tiny — banners are rotated client-side. Sorted newest first
   * so a freshly-uploaded campaign is the first one users see.
   */
  async listPublic(args: GetAdvertisementsArgs): Promise<Advertisement[]> {
    const query: FilterQuery<Advertisement> = {};
    if (args.filter?.type) query.type = args.filter.type;

    return this.advertisementModel
      .find(query)
      .sort({ createdAt: -1 })
      .limit(20)
      .lean<Advertisement[]>();
  }

  async create(data: AdvertisementInput): Promise<Advertisement> {
    this.assertBannerImageRef(data.bannerImageUrl, 'bannerImageUrl');
    this.assertLinkRef(data.link, 'link');
    await this.assertNoDuplicate(data);

    return this.advertisementModel.create({
      type: data.type,
      bannerImageUrl: data.bannerImageUrl.trim(),
      title: data.title.trim(),
      link: data.link.trim(),
    });
  }

  async update(
    advertisementId: Types.ObjectId,
    data: AdvertisementInput,
  ): Promise<Advertisement> {
    this.assertBannerImageRef(data.bannerImageUrl, 'bannerImageUrl');
    this.assertLinkRef(data.link, 'link');
    await this.assertNoDuplicate(data, advertisementId);

    const updated = await this.advertisementModel.findByIdAndUpdate(
      advertisementId,
      {
        $set: {
          type: data.type,
          bannerImageUrl: data.bannerImageUrl.trim(),
          title: data.title.trim(),
          link: data.link.trim(),
        },
      },
      { new: true },
    );
    if (!updated) throw new BadRequestException('Advertisement not found');
    return updated;
  }

  async delete(advertisementId: Types.ObjectId): Promise<boolean> {
    const res = await this.advertisementModel.deleteOne({ _id: advertisementId });
    if (res.deletedCount === 0) {
      throw new BadRequestException('Advertisement not found');
    }
    return true;
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
