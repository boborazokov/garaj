import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { OrderModel } from 'src/modules/order/model';
import { PartModel } from 'src/modules/part/model';
import { ServiceModel } from 'src/modules/service/model/service.model';
import { WorkshopModel } from 'src/modules/workshop/model';
import { PromotionPaymentModel } from '../model';
import { PromotionPaymentResolver } from '../resolver';
import { PromotionPaymentService } from '../service';

@Module({
  imports: [
    MongooseModule.forFeature([
      PromotionPaymentModel,
      PartModel,
      OrderModel,
      ServiceModel,
      WorkshopModel,
    ]),
  ],
  providers: [PromotionPaymentResolver, PromotionPaymentService],
  exports: [PromotionPaymentService],
})
export class PromotionPaymentModule {}
