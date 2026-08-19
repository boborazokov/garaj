import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { WorkshopModel } from 'src/modules/workshop/model';
import { MinioModule } from 'src/utils/minio';
import { WorkshopReviewModel } from '../model/workshop-review.model';
import { WorkshopReviewService } from '../service/workshop-review.service';

@Module({
  imports: [
    MongooseModule.forFeature([WorkshopReviewModel, WorkshopModel]),
    MinioModule,
  ],
  providers: [WorkshopReviewService],
  exports: [WorkshopReviewService],
})
export class WorkshopReviewModule {}
