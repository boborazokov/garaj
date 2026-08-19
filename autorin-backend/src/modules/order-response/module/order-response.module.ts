import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { OrderModel } from 'src/modules/order/model';
import { PartModel } from 'src/modules/part/model';
import { PushModule } from 'src/services/push/push.module';
import { OrderResponseModel } from '../model/order-response.model';
import { OrderResponseResolver } from '../resolver/order-response.resolver';
import { OrderResponseService } from '../service/order-response.service';

@Module({
  imports: [
    MongooseModule.forFeature([OrderResponseModel, OrderModel, PartModel]),
    PushModule,
  ],
  providers: [OrderResponseService, OrderResponseResolver],
  exports: [OrderResponseService],
})
export class OrderResponseModule {}
