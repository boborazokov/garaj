import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { WalletModule } from 'src/modules/wallet/module';
import { AdvertisementModel } from '../model';
import { AdvertisementResolver } from '../resolver';
import { AdvertisementService } from '../service';

@Module({
  imports: [
    MongooseModule.forFeature([AdvertisementModel]),
    WalletModule,
  ],
  providers: [AdvertisementResolver, AdvertisementService],
  exports: [AdvertisementService],
})
export class AdvertisementModule {}
