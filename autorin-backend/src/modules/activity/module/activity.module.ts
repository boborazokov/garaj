import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserActivityModel } from '../model/user-activity.model';
import { ActivityResolver } from '../resolver/activity.resolver';
import { ActivityService } from '../service/activity.service';

@Module({
  imports: [MongooseModule.forFeature([UserActivityModel])],
  providers: [ActivityService, ActivityResolver],
  exports: [ActivityService],
})
export class ActivityModule {}
