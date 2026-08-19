import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PartModel } from 'src/modules/part/model';
import { ServiceModel } from 'src/modules/service/model/service.model';
import { RedisCacheModule } from 'src/services/redis-cache/redis-cache.module';
import { WorkshopCategoryModel } from 'src/modules/workshop-category/model/workshop-category.model';
import { WorkshopModel } from '../model';
import { WorkshopResolver } from '../resolver';
import { WorkshopDiscoveryService } from '../service/workshop-discovery.service';
import { WorkshopGeospatialService } from '../service/workshop-geospatial.service';
import { WorkshopService } from '../service';
import { MinioModule } from 'src/utils/minio';
import { ViewModule } from 'src/modules/view/module';
import { WorkshopCategoryModule } from 'src/modules/workshop-category/module/workshop-category.module';
import { WorkshopReviewModule } from 'src/modules/workshop-review/module/workshop-review.module';
import { WorkshopBookingModule } from 'src/modules/workshop-booking/module/workshop-booking.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      WorkshopModel,
      PartModel,
      ServiceModel,
      WorkshopCategoryModel,
    ]),
    RedisCacheModule,
    MinioModule,
    ViewModule,
    WorkshopCategoryModule,
    WorkshopReviewModule,
    WorkshopBookingModule,
  ],
  providers: [
    WorkshopResolver,
    WorkshopService,
    WorkshopDiscoveryService,
    WorkshopGeospatialService,
  ],
  exports: [WorkshopService, WorkshopDiscoveryService, WorkshopGeospatialService],
})
export class WorkshopModule {}
