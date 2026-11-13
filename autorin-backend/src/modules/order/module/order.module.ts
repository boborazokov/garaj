import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PartModel } from 'src/modules/part/model';
import { ViewModule } from 'src/modules/view/module';
import { PushModule } from 'src/services/push';
import { OrderModel } from '../model';
import { OrderFieldsResolver, OrderResolver } from '../resolver';
import { OrderService } from '../service';

@Module({
  imports: [
    MongooseModule.forFeature([OrderModel, PartModel]),
    PushModule,
    ViewModule,
  ],
  providers: [OrderResolver, OrderFieldsResolver, OrderService],
  exports: [OrderService],
})
export class OrderModule {}
