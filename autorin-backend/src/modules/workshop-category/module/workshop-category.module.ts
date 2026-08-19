import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { WorkshopCategoryModel } from '../model/workshop-category.model';
import { WorkshopCategoryResolver } from '../resolver/workshop-category.resolver';
import { WorkshopCategoryService } from '../service/workshop-category.service';

@Module({
  imports: [MongooseModule.forFeature([WorkshopCategoryModel])],
  providers: [WorkshopCategoryService, WorkshopCategoryResolver],
  exports: [WorkshopCategoryService],
})
export class WorkshopCategoryModule {}
