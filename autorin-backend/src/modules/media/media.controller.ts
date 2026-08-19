import {
  Controller,
  Get,
  NotFoundException,
  Req,
  Res,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { Public } from 'src/auth/decorators';
import { MinioService } from 'src/utils/minio';

@Controller('media')
export class MediaController {
  constructor(private readonly minioService: MinioService) {}

  /** Public file proxy — same host as API (works with one ngrok tunnel). */
  @Public()
  @Get('*')
  async serve(@Req() req: Request, @Res() res: Response) {
    const storagePath = req.path.replace(/^\/media\/?/, '');
    if (!storagePath) {
      throw new NotFoundException();
    }

    try {
      const { stream, contentType } =
        await this.minioService.openStoragePath(storagePath);
      res.setHeader('Content-Type', contentType);
      res.setHeader('Cache-Control', 'public, max-age=86400');
      stream.pipe(res);
    } catch {
      throw new NotFoundException();
    }
  }
}
