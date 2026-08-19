import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { BookServiceInput } from '../dto/book-service.input';
import { ServiceBooking } from '../schema/service-booking.schema';
import { ServiceBookingStatusEnum } from '../enums/service-booking-status.enum';

@Injectable()
export class ServiceBookingService {
  constructor(
    @InjectModel(COLLECTIONS.SERVICE_BOOKINGS)
    private readonly bookingModel: Model<ServiceBooking>,
    @InjectModel(COLLECTIONS.SERVICES)
    private readonly serviceModel: Model<AutoService>,
  ) {}

  async bookService(data: BookServiceInput, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const service = await this.serviceModel.findOne({
      _id: data.serviceId,
      status: ItemStatusEnum.ACTIVE,
    });
    if (!service) throw new BadRequestException('Service not found');
    if (service.owner.toString() === userId.toString()) {
      throw new BadRequestException('Cannot book your own service');
    }

    return this.bookingModel.create({
      service: service._id,
      user: new Types.ObjectId(userId),
      scheduledAt: data.scheduledAt,
      notes: data.notes?.trim() ?? '',
      status: ServiceBookingStatusEnum.PENDING,
    });
  }

  myBookings(context: ContextType) {
    const { userId } = assertAuthenticated(context);
    return this.bookingModel
      .find({ user: new Types.ObjectId(userId) })
      .sort({ scheduledAt: -1 })
      .populate('service')
      .lean();
  }
}
