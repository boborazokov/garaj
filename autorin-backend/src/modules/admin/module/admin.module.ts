import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PartModel } from 'src/modules/part/model';
import { SearchModule } from 'src/modules/search/module/search.module';
import { UserModel } from 'src/modules/user/model';
import { OrderModel } from 'src/modules/order/model/order.model';
import { CategoryModel } from 'src/modules/category/model';
import { WorkshopModel } from 'src/modules/workshop/model';
import { UserModule } from 'src/modules/user/module';
import { PromotionPaymentModule } from 'src/modules/promotion-payment/module';
import { AdvertisementModule } from 'src/modules/advertisement/module';
import { PushModule } from 'src/services/push';
import { AdminResolver } from '../resolver/admin.resolver';
import { AdminService } from '../service/admin.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      UserModel,
      PartModel,
      OrderModel,
      CategoryModel,
      WorkshopModel,
    ]),
    SearchModule,
    UserModule,
    PushModule,
    PromotionPaymentModule,
    AdvertisementModule,
  ],
  providers: [AdminResolver, AdminService],
})
export class AdminModule {}
