import { Global, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { UserActivityModel } from 'src/modules/activity/model/user-activity.model';
import { PartModel } from 'src/modules/part/model';
import { UserModel } from 'src/modules/user/model';
import { OrderModel } from 'src/modules/order/model/order.model';
import { DailyUserVisitModel } from '../model/daily-user-visit.model';
import { AnalyticsService } from '../service/analytics.service';

@Global()
@Module({
  imports: [
    MongooseModule.forFeature([
      DailyUserVisitModel,
      UserModel,
      PartModel,
      OrderModel,
      UserActivityModel,
    ]),
  ],
  providers: [AnalyticsService],
  exports: [AnalyticsService],
})
export class AnalyticsModule {}
