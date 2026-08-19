import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CategoryModel } from '../model';
import { CategoryResolver } from '../resolver';
import { CategoryService } from '../service';

@Module({
  imports: [MongooseModule.forFeature([CategoryModel])],
  providers: [CategoryResolver, CategoryService],
  exports: [CategoryService],
})
export class CategoryModule {}
