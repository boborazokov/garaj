import {
  Body,
  Controller,
  Post,
  Req,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { Throttle } from '@nestjs/throttler';
import { UploadService } from '../service';
import { UploadFileDto, UploadFilesDto } from '../dto';
import { ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { UseAuth, UseRole } from 'src/auth/useAuth';
import { UserRoleEnum } from 'src/modules/user/enums';
import { ContextType } from 'src/auth/interfaces';
import { uploadMulterOptions } from 'src/common/upload/multer-options.factory';

@Controller('upload')
export class UploadController {
  constructor(private uploadService: UploadService) {}

  @ApiBearerAuth()
  @UseRole(UserRoleEnum.ADMIN)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Post('category-icon')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('file', 1, uploadMulterOptions))
  uploadCategoryIcon(
    @UploadedFiles() files: Express.Multer.File[],
    @Req() context: ContextType,
  ) {
    return this.uploadService.uploadCategoryIcon(files?.[0], context);
  }

  @ApiBearerAuth()
  @UseRole(UserRoleEnum.ADMIN)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Post('advertisement-banner')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('file', 1, uploadMulterOptions))
  uploadAdvertisementBanner(
    @UploadedFiles() files: Express.Multer.File[],
    @Req() context: ContextType,
  ) {
    return this.uploadService.uploadAdvertisementBanner(files?.[0], context);
  }

  @ApiBearerAuth()
  @UseAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Post('single')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('file', 1, uploadMulterOptions))
  uploadFile(
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: UploadFileDto,
    @Req() context: ContextType,
  ) {
    return this.uploadService.uploadFile(files?.[0], body, context);
  }

  @ApiBearerAuth()
  @UseAuth()
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @Post('multiple')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('files', 10, uploadMulterOptions))
  uploadFiles(
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: UploadFilesDto,
    @Req() context: ContextType,
  ) {
    return this.uploadService.uploadMultipleFiles(files, body, context);
  }

  @ApiBearerAuth()
  @UseAuth()
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @Post('chat-image')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('file', 1, uploadMulterOptions))
  async uploadChatImage(
    @UploadedFiles() files: Express.Multer.File[],
    @Req() context: ContextType,
  ): Promise<{ url: string }> {
    const url = await this.uploadService.uploadChatImage(files?.[0], context);
    return { url };
  }

  @ApiBearerAuth()
  @UseAuth()
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @Post('chat-voice')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('file', 1, uploadMulterOptions))
  async uploadChatVoice(
    @UploadedFiles() files: Express.Multer.File[],
    @Req() context: ContextType,
  ): Promise<{ url: string }> {
    const url = await this.uploadService.uploadChatVoice(files?.[0], context);
    return { url };
  }
}
