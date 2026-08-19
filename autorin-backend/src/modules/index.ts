import { Module } from '@nestjs/common';

import { AuthModule } from './auth/module';
import { UserModule } from './user/module';
import { PartModule } from './part/module';
import { ViewModule } from './view/module';
import { UploadModule } from './upload/module';
import { MediaModule } from './media';
import { FavoriteModule } from './favorite/module';
import { CategoryModule } from './category/module';
import { WorkshopModule } from './workshop/module';
import { WorkshopCategoryModule } from './workshop-category/module/workshop-category.module';
import { ServiceCategoryModule } from './service-category/module/service-category.module';
import { ServiceListingModule } from './service/module/service.module';
import { AdvertisementModule } from './advertisement/module';
import { OrderModule } from './order/module';
import { OrderResponseModule } from './order-response/module/order-response.module';
import { ConversationModule } from './conversation/module';
import { MessageModule } from './message/module';
import { DeviceTokenModule } from './device-token/module';
import { ActivityModule } from './activity/module/activity.module';
import { SearchModule } from './search/module/search.module';
import { RecommendationModule } from './recommendation/module/recommendation.module';
import { TrendingModule } from './trending/module/trending.module';
import { PushModule } from 'src/services/push';
import { PubSubModule } from 'src/pubsub';
import { AppSettingsModule } from './app-settings/module/app-settings.module';
import { AnalyticsModule } from './analytics/module/analytics.module';
import { AdminModule } from './admin/module/admin.module';
import { SellerProfileModule } from './seller-profile/module/seller-profile.module';
import { UserNotificationModule } from './user-notification/module/user-notification.module';

const modules = [
  PubSubModule,
  AppSettingsModule,
  AnalyticsModule,
  AuthModule,
  UserModule,
  ActivityModule,
  TrendingModule,
  SearchModule,
  RecommendationModule,
  PartModule,
  ViewModule,
  UploadModule,
  MediaModule,
  FavoriteModule,
  CategoryModule,
  WorkshopModule,
  WorkshopCategoryModule,
  ServiceCategoryModule,
  ServiceListingModule,
  AdvertisementModule,
  OrderModule,
  OrderResponseModule,
  DeviceTokenModule,
  PushModule,
  ConversationModule,
  MessageModule,
  AdminModule,
  SellerProfileModule,
  UserNotificationModule,
];

@Module({ imports: modules })
export class Modules {}
