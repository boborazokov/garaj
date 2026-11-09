import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { BOOKING_PLATFORM_FEE_UZS } from 'src/modules/wallet/constants/booking-fee';
import { WalletService } from 'src/modules/wallet/service';
import { CurrencyEnum } from 'src/shared/enums';
import { BookServiceInput } from '../dto/book-service.input';
import { ServiceBookingPaymentStatusEnum } from '../enums/service-booking-payment-status.enum';
import { ServiceBookingStatusEnum } from '../enums/service-booking-status.enum';
import { ServiceBooking } from '../schema/service-booking.schema';

@Injectable()
export class ServiceBookingService {
  constructor(
    @InjectModel(COLLECTIONS.SERVICE_BOOKINGS)
    private readonly bookingModel: Model<ServiceBooking>,
    @InjectModel(COLLECTIONS.SERVICES)
    private readonly serviceModel: Model<AutoService>,
    private readonly walletService: WalletService,
  ) {}

  async bookService(data: BookServiceInput, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const userObjectId = new Types.ObjectId(userId);
    const service = await this.serviceModel.findOne({
      _id: data.serviceId,
      status: ItemStatusEnum.ACTIVE,
    });
    if (!service) throw new BadRequestException('Service not found');
    if (service.owner.toString() === userId.toString()) {
      throw new BadRequestException('Cannot book your own service');
    }

    const amount =
      data.amount != null && Number.isFinite(data.amount) && data.amount > 0
        ? Math.floor(data.amount)
        : BOOKING_PLATFORM_FEE_UZS;

    const booking = await this.bookingModel.create({
      service: service._id,
      user: userObjectId,
      scheduledAt: data.scheduledAt,
      notes: data.notes?.trim() ?? '',
      status: ServiceBookingStatusEnum.PENDING,
      paidAmount: amount,
      currency: CurrencyEnum.UZS,
      paymentStatus: ServiceBookingPaymentStatusEnum.UNPAID,
      walletTransactionId: null,
    });

    try {
      const walletTx = await this.walletService.debitForBooking({
        userId: userObjectId,
        amount,
        bookingId: booking._id,
      });
      booking.paymentStatus = ServiceBookingPaymentStatusEnum.PAID;
      booking.walletTransactionId = walletTx._id;
      await booking.save();
    } catch (err) {
      booking.paymentStatus = ServiceBookingPaymentStatusEnum.FAILED;
      await booking.save();
      await this.bookingModel.deleteOne({ _id: booking._id });
      const message =
        err instanceof Error ? err.message : 'Wallet debit failed';
      if (message === 'INSUFFICIENT_WALLET_BALANCE') {
        throw new BadRequestException(
          'INSUFFICIENT_WALLET_BALANCE: Top up your wallet to book this service.',
        );
      }
      throw new BadRequestException(message);
    }

    return booking;
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
