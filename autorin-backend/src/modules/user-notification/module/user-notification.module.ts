import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserNotificationModel } from '../model/user-notification.model';
import { UserNotificationResolver } from '../resolver/user-notification.resolver';
import { UserNotificationService } from '../service/user-notification.service';

@Module({
  imports: [MongooseModule.forFeature([UserNotificationModel])],
  providers: [UserNotificationService, UserNotificationResolver],
  exports: [UserNotificationService],
})
export class UserNotificationModule {}
