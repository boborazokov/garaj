import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DeviceTokenModel } from '../model';
import { DeviceTokenResolver } from '../resolver';
import { DeviceTokenService } from '../service';

@Module({
  imports: [MongooseModule.forFeature([DeviceTokenModel])],
  providers: [DeviceTokenResolver, DeviceTokenService],
  exports: [DeviceTokenService],
})
export class DeviceTokenModule {}
