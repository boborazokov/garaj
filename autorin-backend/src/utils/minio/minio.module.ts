import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { MinioService } from './minio.service';
import { MINIO_CLIENT_PROVIDER } from './minio.provider';
import { CompressorModule } from '../../utils/compressor';

@Module({
  exports: [MinioService],
  imports: [ConfigModule, CompressorModule],
  providers: [MINIO_CLIENT_PROVIDER, MinioService],
})
export class MinioModule {}
