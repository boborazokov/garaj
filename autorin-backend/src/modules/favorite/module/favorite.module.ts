import { MongooseModule } from '@nestjs/mongoose';
import { FavoriteModel } from '../model';
import { Module } from '@nestjs/common';
import { FavoriteService } from '../service';
import { FavoriteResolver } from '../resolver';

@Module({
  imports: [MongooseModule.forFeature([FavoriteModel])],
  providers: [FavoriteResolver, FavoriteService],
  exports: [FavoriteService],
})
export class FavoriteModule {}
