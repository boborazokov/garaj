import { Module } from '@nestjs/common';
import { Configs } from './configs';
import { Modules } from './modules';

@Module({
  imports: [Configs, Modules],
})
export class AppModule {}
