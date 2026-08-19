import { Module } from '@nestjs/common';

import { CompressorService } from './compressor.service';

@Module({
  exports: [CompressorService],
  providers: [CompressorService],
})
export class CompressorModule {}
