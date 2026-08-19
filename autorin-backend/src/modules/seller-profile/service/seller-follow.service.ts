import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { PaginationInput, LIMIT_DEFAULT, PAGE_DEFAULT } from 'src/shared/inputs';
import { PushService } from 'src/services/push/push.service';
import { SellerFollow } from '../schema/seller-follow.schema';
import { PaginatedSellerFollowers, SellerFollower } from '../types';

@Injectable()
export class SellerFollowService {
  constructor(
    @InjectModel(COLLECTIONS.SELLER_FOLLOWS)
    private readonly followModel: Model<SellerFollow>,
    @InjectModel(COLLECTIONS.USERS)
    private readonly userModel: Model<Record<string, unknown>>,
    private readonly push: PushService,
  ) {}

  async follow(followerId: string, sellerId: string): Promise<boolean> {
    this.assertIds(followerId, sellerId);
    if (followerId === sellerId) {
      throw new BadRequestException('Cannot follow yourself');
    }

    const sellerExists = await this.userModel.exists({
      _id: new Types.ObjectId(sellerId),
    });
    if (!sellerExists) {
      throw new BadRequestException('Seller not found');
    }

    const result = await this.followModel.updateOne(
      {
        followerId: new Types.ObjectId(followerId),
        sellerId: new Types.ObjectId(sellerId),
      },
      { $setOnInsert: { createdAt: new Date() } },
      { upsert: true },
    );

    if (result.upsertedCount > 0) {
      const follower = await this.userModel
        .findById(followerId)
        .select('name')
        .lean()
        .exec();
      const followerName =
        typeof follower?.name === 'string' && follower.name.trim()
          ? follower.name.trim()
          : 'Someone';
      this.push.enqueueNewFollower({
        recipientIds: [sellerId],
        followerId,
        followerName,
      });
    }

    return true;
  }

  async unfollow(followerId: string, sellerId: string): Promise<boolean> {
    this.assertIds(followerId, sellerId);
    await this.followModel.deleteOne({
      followerId: new Types.ObjectId(followerId),
      sellerId: new Types.ObjectId(sellerId),
    });
    return true;
  }

  async listFollowersForOwner(
    sellerId: string,
    viewerId: string,
    pagination?: PaginationInput,
  ): Promise<PaginatedSellerFollowers> {
    this.assertIds(viewerId, sellerId);
    if (sellerId !== viewerId) {
      throw new ForbiddenException('Only the store owner can view followers');
    }

    const page = Math.max(1, pagination?.page ?? PAGE_DEFAULT);
    const limit = Math.min(50, Math.max(1, pagination?.limit ?? LIMIT_DEFAULT));
    const sellerOid = new Types.ObjectId(sellerId);
    const filter = { sellerId: sellerOid };

    const [totalDocs, rows] = await Promise.all([
      this.followModel.countDocuments(filter),
      this.followModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate({
          path: 'followerId',
          select: 'name username image deletedAt',
          match: { deletedAt: null },
        })
        .lean()
        .exec(),
    ]);

    const payload: SellerFollower[] = rows
      .filter((row) => row.followerId && typeof row.followerId === 'object')
      .map((row) => {
        const user = row.followerId as {
          _id: Types.ObjectId;
          name?: string;
          username?: string;
          image?: string;
        };
        return {
          _id: user._id,
          name: user.name?.trim() || 'User',
          username: user.username?.trim() || undefined,
          image: user.image?.trim() || undefined,
          followedAt: row.createdAt,
        };
      });

    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));

    return {
      payload,
      totalDocs,
      limit,
      page,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
      prevPage: page > 1 ? page - 1 : undefined,
      nextPage: page < totalPages ? page + 1 : undefined,
    };
  }

  private assertIds(followerId: string, sellerId: string) {
    if (!Types.ObjectId.isValid(followerId) || !Types.ObjectId.isValid(sellerId)) {
      throw new BadRequestException('Invalid user id');
    }
  }
}
