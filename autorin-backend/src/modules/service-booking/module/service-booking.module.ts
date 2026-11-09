import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ServiceModel } from 'src/modules/service/model/service.model';
import { WalletModule } from 'src/modules/wallet/module';
import { ServiceBookingModel } from '../model/service-booking.model';
import { ServiceBookingResolver } from '../resolver/service-booking.resolver';
import { ServiceBookingService } from '../service/service-booking.service';

@Module({
  imports: [
    WalletModule,
    MongooseModule.forFeature([ServiceBookingModel, ServiceModel]),
  ],
  providers: [ServiceBookingService, ServiceBookingResolver],
  exports: [ServiceBookingService],
})
export class ServiceBookingModule {}
