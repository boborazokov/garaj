import { ApiProperty } from '@nestjs/swagger';
import { FilesTargetDto } from './files-target.dto';

export class UploadFilesDto {
  @ApiProperty()
  target: FilesTargetDto;

  @ApiProperty({
    type: 'string',
    format: 'binary',
  })
  files: Express.Multer.File[];
}
