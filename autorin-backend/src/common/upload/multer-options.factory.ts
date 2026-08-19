import { ConfigService } from '@nestjs/config';
import { MulterOptions } from '@nestjs/platform-express/multer/interfaces/multer-options.interface';
import { memoryStorage } from 'multer';

function resolveMaxBytes(config?: ConfigService): number {
  return Number(
    config?.get('UPLOAD_MAX_FILE_BYTES') ??
      process.env.UPLOAD_MAX_FILE_BYTES ??
      10_485_760,
  );
}

export function createMulterOptions(config?: ConfigService): MulterOptions {
  const maxBytes = resolveMaxBytes(config);

  return {
    storage: memoryStorage(),
    limits: {
      fileSize: maxBytes,
      files: 10,
    },
  };
}

/** For `@UseInterceptors` decorators (evaluated before DI). Reads validated `process.env`. */
export const uploadMulterOptions = createMulterOptions();
