import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PartModel } from 'src/modules/part/model';
import { PushModule } from 'src/services/push';
import { OrderModel } from '../model';
import { OrderResolver } from '../resolver';
import { OrderService } from '../service';

@Module({
  imports: [
    MongooseModule.forFeature([OrderModel, PartModel]),
    PushModule,
  ],
  providers: [OrderResolver, OrderService],
  exports: [OrderService],
})
export class OrderModule {}
