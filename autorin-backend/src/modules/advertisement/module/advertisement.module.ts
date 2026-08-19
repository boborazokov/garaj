import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AdvertisementModel } from '../model';
import { AdvertisementResolver } from '../resolver';
import { AdvertisementService } from '../service';

@Module({
  imports: [MongooseModule.forFeature([AdvertisementModel])],
  providers: [AdvertisementResolver, AdvertisementService],
  exports: [AdvertisementService],
})
export class AdvertisementModule {}
