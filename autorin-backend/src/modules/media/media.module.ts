import { Module } from '@nestjs/common';
import { MinioModule } from 'src/utils/minio';
import { MediaController } from './media.controller';

@Module({
  imports: [MinioModule],
  controllers: [MediaController],
})
export class MediaModule {}
