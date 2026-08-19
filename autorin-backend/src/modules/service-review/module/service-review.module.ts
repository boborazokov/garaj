import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ServiceModel } from 'src/modules/service/model/service.model';
import { ServiceReviewModel } from '../model/service-review.model';
import { ServiceReviewService } from '../service/service-review.service';

@Module({
  imports: [MongooseModule.forFeature([ServiceReviewModel, ServiceModel])],
  providers: [ServiceReviewService],
  exports: [ServiceReviewService],
})
export class ServiceReviewModule {}
