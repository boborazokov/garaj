import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { WorkshopModel } from 'src/modules/workshop/model';
import { WorkshopBookingModel } from '../model/workshop-booking.model';
import { WorkshopBookingResolver } from '../resolver/workshop-booking.resolver';
import { WorkshopBookingService } from '../service/workshop-booking.service';

@Module({
  imports: [MongooseModule.forFeature([WorkshopBookingModel, WorkshopModel])],
  providers: [WorkshopBookingService, WorkshopBookingResolver],
  exports: [WorkshopBookingService],
})
export class WorkshopBookingModule {}
