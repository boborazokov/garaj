import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId } from 'class-validator';

export class FilesTargetDto {
  @ApiProperty({ required: false })
  @IsMongoId({ always: false })
  partId?: string;

  @ApiProperty({ required: false })
  @IsMongoId({ always: false })
  workshopId?: string;

  @ApiProperty({ required: false })
  @IsMongoId({ always: false })
  orderId?: string;
}
