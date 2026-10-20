import { Global, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppSettingsModel } from '../model';
import { AppSettingsResolver } from '../resolver/app-settings.resolver';
import { AppSettingsService } from '../service';

@Global()
@Module({
  imports: [MongooseModule.forFeature([AppSettingsModel])],
  providers: [AppSettingsService, AppSettingsResolver],
  exports: [AppSettingsService],
})
export class AppSettingsModule {}
