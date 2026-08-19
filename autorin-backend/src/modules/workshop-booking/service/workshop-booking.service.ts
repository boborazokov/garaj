import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Workshop } from 'src/modules/workshop/schema/workshop.schema';
import { BookWorkshopInput } from '../dto/book-workshop.input';
import { WorkshopBookingStatusEnum } from '../enums/workshop-booking-status.enum';
import { WorkshopBooking } from '../schema/workshop-booking.schema';

@Injectable()
export class WorkshopBookingService {
  constructor(
    @InjectModel(COLLECTIONS.WORKSHOP_BOOKINGS)
    private readonly bookingModel: Model<WorkshopBooking>,
    @InjectModel(COLLECTIONS.WORKSHOPS)
    private readonly workshopModel: Model<Workshop>,
  ) {}

  async bookWorkshop(data: BookWorkshopInput, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const workshop = await this.workshopModel.findOne({
      _id: data.workshopId,
      status: ItemStatusEnum.ACTIVE,
    });
    if (!workshop) throw new BadRequestException('Workshop not found');
    if (workshop.owner.toString() === userId.toString()) {
      throw new BadRequestException('Cannot book your own workshop');
    }

    const booking = await this.bookingModel.create({
      workshop: workshop._id,
      user: new Types.ObjectId(userId),
      scheduledAt: data.scheduledAt,
      notes: data.notes?.trim() ?? '',
      serviceLabel: data.serviceLabel?.trim() ?? '',
      status: WorkshopBookingStatusEnum.PENDING,
    });
    await this.incrementBookingCount(workshop._id);
    return booking;
  }

  myBookings(context: ContextType) {
    const { userId } = assertAuthenticated(context);
    return this.bookingModel
      .find({ user: new Types.ObjectId(userId) })
      .sort({ scheduledAt: -1 })
      .populate({
        path: 'workshop',
        populate: { path: 'owner', select: 'name phone' },
      })
      .lean();
  }

  async incrementBookingCount(workshopId: Types.ObjectId) {
    await this.workshopModel.updateOne(
      { _id: workshopId },
      { $inc: { bookingCount: 1 } },
    );
  }
}
