import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { AddReviewInput } from '../dto/add-review.input';
import { ServiceReview } from '../schema/service-review.schema';

@Injectable()
export class ServiceReviewService {
  constructor(
    @InjectModel(COLLECTIONS.SERVICE_REVIEWS)
    private readonly reviewModel: Model<ServiceReview>,
    @InjectModel(COLLECTIONS.SERVICES)
    private readonly serviceModel: Model<AutoService>,
  ) {}

  async addReview(data: AddReviewInput, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const rating = Math.min(5, Math.max(1, data.rating));

    const service = await this.serviceModel.findById(data.serviceId);
    if (!service) throw new BadRequestException('Service not found');

    const existing = await this.reviewModel.findOne({
      service: service._id,
      user: new Types.ObjectId(userId),
    });
    if (existing) throw new BadRequestException('You already reviewed this service');

    const review = await this.reviewModel.create({
      service: service._id,
      user: new Types.ObjectId(userId),
      rating,
      text: data.text?.trim() ?? '',
    });

    const stats = await this.reviewModel.aggregate([
      { $match: { service: service._id } },
      {
        $group: {
          _id: '$service',
          avg: { $avg: '$rating' },
          count: { $sum: 1 },
        },
      },
    ]);

    const row = stats[0];
    if (row) {
      await this.serviceModel.updateOne(
        { _id: service._id },
        {
          $set: {
            rating: Math.round(row.avg * 10) / 10,
            reviewCount: row.count,
          },
        },
      );
    }

    return this.reviewModel
      .findById(review._id)
      .populate('user', 'name phone')
      .exec();
  }

  listForService(serviceId: string) {
    return this.reviewModel
      .find({ service: new Types.ObjectId(serviceId) })
      .sort({ createdAt: -1 })
      .populate('user', 'name phone')
      .limit(50)
      .lean();
  }
}
