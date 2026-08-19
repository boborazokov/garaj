import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserActivityModel } from 'src/modules/activity/model/user-activity.model';
import { FavoriteModel } from 'src/modules/favorite/model';
import { MessageModel } from 'src/modules/message/model';
import { PartModel } from 'src/modules/part/model';
import { ViewModel } from 'src/modules/view/model';
import { TrendingSchedule } from '../schedule/trending.schedule';
import { TrendingService } from '../service/trending.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      PartModel,
      ViewModel,
      FavoriteModel,
      MessageModel,
      UserActivityModel,
    ]),
  ],
  providers: [TrendingService, TrendingSchedule],
  exports: [TrendingService],
})
export class TrendingModule {}
