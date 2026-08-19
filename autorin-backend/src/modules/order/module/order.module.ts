import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { OrderModel } from '../model';
import { OrderResolver } from '../resolver';
import { OrderService } from '../service';

@Module({
  imports: [MongooseModule.forFeature([OrderModel])],
  providers: [OrderResolver, OrderService],
  exports: [OrderService],
})
export class OrderModule {}
