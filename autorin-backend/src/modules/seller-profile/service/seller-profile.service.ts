import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { User } from 'src/modules/user/schema';
import {
  SellerCategoryStat,
  SellerStoreProfile,
  SellerStoreStats,
} from '../types/seller-profile-public.type';
import { SellerProfileView } from '../schema/seller-profile-view.schema';

@Injectable()
export class SellerProfileService {
  constructor(
    @InjectModel(COLLECTIONS.USERS) private readonly userModel: Model<User>,
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Record<string, unknown>>,
    @InjectModel(COLLECTIONS.SELLER_PROFILE_VIEWS)
    private readonly profileViewModel: Model<SellerProfileView>,
  ) {}

  async getSellerProfile(
    sellerId: string,
    viewerId?: string,
  ): Promise<SellerStoreProfile> {
    if (!Types.ObjectId.isValid(sellerId)) {
      throw new BadRequestException('Invalid seller id');
    }

    const sellerOid = new Types.ObjectId(sellerId);
    const user = await this.userModel.findById(sellerOid).lean().exec();
    if (!user) {
      throw new NotFoundException('Seller not found');
    }

    const sellerIdStr = sellerOid.toString();
    const isOwnProfile = viewerId != null && viewerId === sellerIdStr;

    let profileViews = user.profileViews ?? 0;
    if (viewerId && !isOwnProfile) {
      profileViews = await this.recordUniqueProfileView(
        sellerOid,
        viewerId,
        profileViews,
      );
    }

    const [totalProducts, activeProducts, categories] = await Promise.all([
      this.partModel.countDocuments({ seller: sellerOid }),
      this.partModel.countDocuments({
        seller: sellerOid,
        status: ItemStatusEnum.ACTIVE,
      }),
      this.aggregateCategories(sellerOid),
    ]);

    const privacy = user.privacy ?? {};
    const showLocation = privacy.showLocation !== false;
    const showPhone = privacy.showPhone === true;

    const social = user.socialLinks ?? {};
    const hasSocial = [
      social.telegram,
      social.instagram,
      social.website,
      social.youtube,
      social.facebook,
    ].some((v) => typeof v === 'string' && v.trim());

    const stats: SellerStoreStats = {
      totalProducts,
      activeProducts,
      categoriesCount: categories.length,
      profileViews,
    };

    return {
      _id: user._id,
      name: user.name,
      image: user.image?.trim() || undefined,
      banner: user.banner?.trim() || undefined,
      phone: showPhone ? user.phone : undefined,
      country: showLocation ? user.country?.trim() || undefined : undefined,
      region: showLocation ? user.region?.trim() || undefined : undefined,
      city: showLocation ? user.city?.trim() || user.address?.trim() || undefined : undefined,
      address: showLocation ? user.address?.trim() || undefined : undefined,
      socialLinks: hasSocial ? social : undefined,
      verified: user.verified === true,
      createdAt: user.createdAt,
      stats,
      categories,
      isOwnProfile,
      allowMessages: privacy.allowMessages !== false,
    };
  }

  /** Counts one profile view per authenticated viewer (repeat visits ignored). */
  private async recordUniqueProfileView(
    sellerOid: Types.ObjectId,
    viewerId: string,
    currentViews: number,
  ): Promise<number> {
    if (!Types.ObjectId.isValid(viewerId)) {
      return currentViews;
    }

    const viewerOid = new Types.ObjectId(viewerId);
    const result = await this.profileViewModel.updateOne(
      { viewerId: viewerOid, sellerId: sellerOid },
      { $setOnInsert: { createdAt: new Date() } },
      { upsert: true },
    );

    if (result.upsertedCount > 0) {
      await this.userModel
        .updateOne({ _id: sellerOid }, { $inc: { profileViews: 1 } })
        .exec();
      return currentViews + 1;
    }

    return currentViews;
  }

  private async aggregateCategories(
    sellerId: Types.ObjectId,
  ): Promise<SellerCategoryStat[]> {
    const rows = await this.partModel
      .aggregate<{
        _id: Types.ObjectId;
        count: number;
        name?: string;
        slug?: string;
      }>([
        {
          $match: {
            seller: sellerId,
            status: ItemStatusEnum.ACTIVE,
            category: { $exists: true, $ne: null },
          },
        },
        { $group: { _id: '$category', productCount: { $sum: 1 } } },
        {
          $lookup: {
            from: COLLECTIONS.CATEGORIES,
            localField: '_id',
            foreignField: '_id',
            as: 'cat',
          },
        },
        { $unwind: { path: '$cat', preserveNullAndEmptyArrays: true } },
        {
          $project: {
            _id: 1,
            productCount: 1,
            name: {
              $ifNull: [
                '$cat.names.ru',
                { $ifNull: ['$cat.names.en', '$cat.name'] },
              ],
            },
            slug: '$cat.key',
          },
        },
        { $sort: { productCount: -1 } },
        { $limit: 24 },
      ])
      .exec();

    return rows.map((r) => ({
      categoryId: r._id,
      name: (r.name as string) || 'Category',
      slug: r.slug as string | undefined,
      productCount: (r as { productCount?: number }).productCount ?? 0,
    }));
  }
}
