import { Global, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppSettingsModel } from '../model';
import { AppSettingsService } from '../service';

@Global()
@Module({
  imports: [MongooseModule.forFeature([AppSettingsModel])],
  providers: [AppSettingsService],
  exports: [AppSettingsService],
})
export class AppSettingsModule {}
