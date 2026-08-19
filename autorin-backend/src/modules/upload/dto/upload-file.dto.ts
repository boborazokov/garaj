import { ApiProperty } from '@nestjs/swagger';
import { FileTargetDto } from './file-target.dto';

export class UploadFileDto {
  @ApiProperty()
  target: FileTargetDto;

  @ApiProperty({ format: 'binary', type: 'string' })
  file: Express.Multer.File;
}
