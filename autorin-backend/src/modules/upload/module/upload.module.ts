import { Module } from '@nestjs/common';
import { UploadController } from '../controller';
import { UploadService } from '../service';
import { MinioModule } from 'src/utils/minio';
import { MongooseModule } from '@nestjs/mongoose';
import { OrderModel } from 'src/modules/order/model';
import { PartModel } from 'src/modules/part/model';
import { WorkshopModel } from 'src/modules/workshop/model';

@Module({
  imports: [
    MinioModule,
    MongooseModule.forFeature([PartModel, WorkshopModel, OrderModel]),
  ],
  providers: [UploadService],
  controllers: [UploadController],
  exports: [UploadService],
})
export class UploadModule {}
