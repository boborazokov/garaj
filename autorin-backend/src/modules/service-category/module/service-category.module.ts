import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ServiceCategoryModel } from '../model/service-category.model';
import { ServiceCategoryResolver } from '../resolver/service-category.resolver';
import { ServiceCategoryService } from '../service/service-category.service';

@Module({
  imports: [MongooseModule.forFeature([ServiceCategoryModel])],
  providers: [ServiceCategoryService, ServiceCategoryResolver],
  exports: [ServiceCategoryService],
})
export class ServiceCategoryModule {}
