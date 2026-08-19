import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { FavoriteModule } from 'src/modules/favorite/module';
import { OrderModel } from 'src/modules/order/model/order.model';
import { PartModel } from 'src/modules/part/model/part.model';
import { ServiceBookingModule } from 'src/modules/service-booking/module/service-booking.module';
import { ServiceReviewModule } from 'src/modules/service-review/module/service-review.module';
import { MinioModule } from 'src/utils/minio';
import { ServiceModel } from '../model/service.model';
import {
  OrderGeoResolver,
  PartGeoResolver,
  ServiceListingResolver,
} from '../resolver/service.resolver';
import { MapDiscoveryService } from '../service/discovery.service';
import { ServiceListingService } from '../service/service.service';

@Module({
  imports: [
    MongooseModule.forFeature([ServiceModel, PartModel, OrderModel]),
    FavoriteModule,
    ServiceBookingModule,
    ServiceReviewModule,
    MinioModule,
  ],
  providers: [
    ServiceListingService,
    MapDiscoveryService,
    ServiceListingResolver,
    PartGeoResolver,
    OrderGeoResolver,
  ],
  exports: [ServiceListingService],
})
export class ServiceListingModule {}
