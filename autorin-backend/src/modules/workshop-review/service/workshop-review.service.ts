import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { Workshop } from 'src/modules/workshop/schema/workshop.schema';
import { FileUpload } from 'graphql-upload-ts';
import { Catalog } from 'src/constants';
import { MinioService } from 'src/utils/minio';
import {
  LIMIT_DEFAULT,
  PAGE_DEFAULT,
  PaginationInput,
} from 'src/shared/inputs';
import { AddWorkshopReviewInput } from '../dto/add-workshop-review.input';
import { ReplyWorkshopReviewInput } from '../dto/reply-workshop-review.input';
import { UpdateWorkshopReviewInput } from '../dto/update-workshop-review.input';
import { WorkshopReview } from '../schema/workshop-review.schema';
import { PaginatedWorkshopReviews } from '../types/paginated-workshop-reviews.type';

@Injectable()
export class WorkshopReviewService {
  constructor(
    @InjectModel(COLLECTIONS.WORKSHOP_REVIEWS)
    private readonly reviewModel: Model<WorkshopReview>,
    @InjectModel(COLLECTIONS.WORKSHOPS)
    private readonly workshopModel: Model<Workshop>,
    private readonly minioService: MinioService,
  ) {}

  private async uploadReviewImages(images?: Promise<FileUpload>[]) {
    if (!images?.length) return [];
    const urls: string[] = [];
    for (const image of images) {
      const file = await this.minioService.prepareFile({
        file: await image,
        compress: false,
      });
      const url = await this.minioService.uploadFile({
        ...file,
        catalog: Catalog.WORKSHOPS_IMAGES,
        compress: true,
      });
      urls.push(url);
    }
    return urls;
  }

  private async refreshWorkshopRating(workshopId: Types.ObjectId) {
    const stats = await this.reviewModel.aggregate([
      { $match: { workshop: workshopId } },
      {
        $group: {
          _id: '$workshop',
          avg: { $avg: '$rating' },
          count: { $sum: 1 },
        },
      },
    ]);
    const row = stats[0];
    if (!row) {
      await this.workshopModel.updateOne(
        { _id: workshopId },
        { $set: { rating: 0, reviewCount: 0 } },
      );
      return;
    }
    await this.workshopModel.updateOne(
      { _id: workshopId },
      {
        $set: {
          rating: Math.round(row.avg * 10) / 10,
          reviewCount: row.count,
        },
      },
    );
  }

  async addReview(
    data: AddWorkshopReviewInput,
    images: Promise<FileUpload>[] | undefined,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const rating = Math.min(5, Math.max(1, data.rating));

    const workshop = await this.workshopModel.findById(data.workshopId);
    if (!workshop) throw new BadRequestException('Workshop not found');
    if (workshop.owner.toString() === userId.toString()) {
      throw new BadRequestException('Cannot review your own workshop');
    }

    const existing = await this.reviewModel.findOne({
      workshop: workshop._id,
      user: new Types.ObjectId(userId),
    });
    if (existing) throw new BadRequestException('You already reviewed this workshop');

    const imageUrls = await this.uploadReviewImages(images);

    const review = await this.reviewModel.create({
      workshop: workshop._id,
      user: new Types.ObjectId(userId),
      rating,
      text: data.text?.trim() ?? '',
      images: imageUrls,
    });

    await this.refreshWorkshopRating(workshop._id);

    return this.reviewModel
      .findById(review._id)
      .populate('user', 'name phone')
      .exec();
  }

  async replyToReview(data: ReplyWorkshopReviewInput, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const review = await this.reviewModel
      .findById(data.reviewId)
      .populate('workshop');
    if (!review) throw new BadRequestException('Review not found');

    const workshop = review.workshop as Workshop;
    if (workshop.owner.toString() !== userId.toString()) {
      throw new BadRequestException('Only the workshop owner can reply');
    }

    review.ownerReply = {
      text: data.text.trim(),
      repliedAt: new Date(),
    };
    await review.save();

    return this.reviewModel
      .findById(review._id)
      .populate('user', 'name phone')
      .exec();
  }

  listForWorkshop(workshopId: string) {
    return this.reviewModel
      .find({ workshop: new Types.ObjectId(workshopId) })
      .sort({ createdAt: -1 })
      .populate('user', 'name phone')
      .limit(50)
      .lean();
  }

  async listForWorkshopPaginated(
    workshopId: string,
    pagination?: PaginationInput,
  ): Promise<PaginatedWorkshopReviews> {
    const page = Math.max(1, pagination?.page ?? PAGE_DEFAULT);
    const limit = Math.min(50, Math.max(1, pagination?.limit ?? LIMIT_DEFAULT));
    const filter = { workshop: new Types.ObjectId(workshopId) };

    const [totalDocs, docs] = await Promise.all([
      this.reviewModel.countDocuments(filter),
      this.reviewModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('user', 'name phone')
        .exec(),
    ]);

    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));

    return {
      payload: docs,
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

  async updateReview(data: UpdateWorkshopReviewInput, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const review = await this.reviewModel.findById(data.reviewId);
    if (!review) throw new BadRequestException('Review not found');
    if (review.user.toString() !== userId.toString()) {
      throw new BadRequestException('You can only edit your own review');
    }

    review.rating = Math.min(5, Math.max(1, data.rating));
    review.text = data.text?.trim() ?? '';
    await review.save();

    await this.refreshWorkshopRating(review.workshop as Types.ObjectId);

    return this.reviewModel
      .findById(review._id)
      .populate('user', 'name phone')
      .exec();
  }

  async deleteReview(reviewId: string, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const review = await this.reviewModel.findById(reviewId);
    if (!review) throw new BadRequestException('Review not found');
    if (review.user.toString() !== userId.toString()) {
      throw new BadRequestException('You can only delete your own review');
    }

    const workshopId = review.workshop as Types.ObjectId;
    await review.deleteOne();
    await this.refreshWorkshopRating(workshopId);

    return true;
  }
}
