import * as sharp from 'sharp';
import { Readable } from 'stream';
import ffmpeg from 'fluent-ffmpeg';
import { Logger, Injectable, BadRequestException } from '@nestjs/common';
import { Catalog } from 'src/constants/buckets.constants';
import { IMAGE_COMPRESS } from 'src/constants/compressor.constants';

export type CompressedFile = {
  fileBuffer: Buffer;
  mimeType: string;
  fileExtension: string;
};

const IMAGE_MIME_PREFIX = 'image/';

@Injectable()
export class CompressorService {
  private readonly logger = new Logger(CompressorService.name);

  async compressFile(
    fileBuffer: Buffer,
    mimeType: string,
    options?: { fileExtension?: string; catalog?: Catalog; maxEdge?: number },
  ): Promise<CompressedFile> {
    if (!fileBuffer?.length) {
      throw new BadRequestException('Invalid file');
    }

    const mime = (mimeType ?? '').toLowerCase().trim();
    const ext = normalizeExtension(options?.fileExtension, mime);

    try {
      if (this.isImageMime(mime)) {
        return await this.compressImage(fileBuffer, mime, ext, options);
      }

      if (mime.startsWith('video/')) {
        return await this.compressVideo(fileBuffer, ext, mime);
      }

      return {
        fileBuffer,
        mimeType: mime || 'application/octet-stream',
        fileExtension: ext ? `.${ext}` : '',
      };
    } catch (error) {
      this.logger.error(`Compression failed for type ${mime}:`, error);
      throw error;
    }
  }

  private isImageMime(mime: string): boolean {
    return mime.startsWith(IMAGE_MIME_PREFIX);
  }

  private maxEdgeForCatalog(catalog?: Catalog, override?: number): number {
    if (override != null && override > 0) return override;
    switch (catalog) {
      case Catalog.USERS_AVATARS:
        return IMAGE_COMPRESS.maxEdge.avatar;
      case Catalog.CATEGORIES_ICONS:
        return IMAGE_COMPRESS.maxEdge.categoryIcon;
      case Catalog.ADVERTISEMENTS_BANNERS:
        return IMAGE_COMPRESS.maxEdge.banner;
      case Catalog.ORDERS_IMAGES:
        return IMAGE_COMPRESS.maxEdge.order;
      case Catalog.WORKSHOPS_IMAGES:
        return IMAGE_COMPRESS.maxEdge.workshop;
      case Catalog.PARTS_IMAGES:
        return IMAGE_COMPRESS.maxEdge.part;
      case Catalog.SERVICES_IMAGES:
        return IMAGE_COMPRESS.maxEdge.service;
      default:
        return IMAGE_COMPRESS.maxEdge.default;
    }
  }

  private async compressImage(
    fileBuffer: Buffer,
    mimeType: string,
    fileExtension: string,
    options?: { catalog?: Catalog; maxEdge?: number },
  ): Promise<CompressedFile> {
    const originalSize = fileBuffer.length;
    const maxEdge = this.maxEdgeForCatalog(options?.catalog, options?.maxEdge);

    try {
      const input = sharp(fileBuffer, { failOn: 'none' }).rotate();
      const metadata = await input.metadata();
      const hasAlpha =
        metadata.hasAlpha === true ||
        mimeType.includes('png') ||
        mimeType.includes('webp') ||
        mimeType.includes('gif');

      let pipeline = input.resize(maxEdge, maxEdge, {
        fit: 'inside',
        withoutEnlargement: true,
      });

      let outputMime: string;
      let outputExt: string;
      let encoded: Buffer;

      if (hasAlpha && metadata.channels && metadata.channels >= 4) {
        outputMime = 'image/webp';
        outputExt = 'webp';
        encoded = await pipeline
          .webp({ quality: IMAGE_COMPRESS.webpQuality, effort: 4 })
          .toBuffer();
      } else {
        outputMime = 'image/jpeg';
        outputExt = 'jpg';
        encoded = await pipeline
          .jpeg({
            quality: IMAGE_COMPRESS.jpegQuality,
            mozjpeg: true,
            progressive: true,
          })
          .toBuffer();
      }

      if (encoded.length >= originalSize && originalSize > 0) {
        encoded = await sharp(fileBuffer, { failOn: 'none' })
          .rotate()
          .resize(maxEdge, maxEdge, {
            fit: 'inside',
            withoutEnlargement: true,
          })
          .jpeg({
            quality: IMAGE_COMPRESS.jpegQualityAggressive,
            mozjpeg: true,
            progressive: true,
          })
          .toBuffer();
        outputMime = 'image/jpeg';
        outputExt = 'jpg';
      }

      if (encoded.length >= originalSize) {
        this.logger.debug(
          `Keeping original (${originalSize}B) — compressed would be ${encoded.length}B`,
        );
        return {
          fileBuffer,
          mimeType: mimeType || 'image/jpeg',
          fileExtension: fileExtension ? `.${fileExtension}` : '.jpg',
        };
      }

      const ratio = ((1 - encoded.length / originalSize) * 100).toFixed(0);
      this.logger.debug(
        `Image ${originalSize}B → ${encoded.length}B (-${ratio}%), maxEdge=${maxEdge}`,
      );

      return {
        fileBuffer: encoded,
        mimeType: outputMime,
        fileExtension: `.${outputExt}`,
      };
    } catch (error) {
      this.logger.error('Image compression failed:', error);
      throw new Error(`Image compression failed: ${(error as Error).message}`);
    }
  }

  private async compressVideo(
    fileBuffer: Buffer,
    fileExtension: string,
    mimeType: string,
  ): Promise<CompressedFile> {
    try {
      const format = fileExtension.replace('.', '') || 'mp4';
      const compressedBuffer = await this.compressVideoWithFfmpeg(
        fileBuffer,
        format,
      );

      return {
        fileExtension: '.mp4',
        mimeType: mimeType || 'video/mp4',
        fileBuffer: compressedBuffer,
      };
    } catch (error) {
      this.logger.error('Video compression failed:', error);
      throw new Error(`Video compression failed: ${(error as Error).message}`);
    }
  }

  private async compressVideoWithFfmpeg(
    buffer: Buffer,
    inputFormat: string,
    outputFormat: string = 'mp4',
  ): Promise<Buffer> {
    return await new Promise<Buffer>((resolve, reject) => {
      const inputStream = new Readable();
      inputStream.push(buffer);
      inputStream.push(null);

      const chunks: Buffer[] = [];

      const command = ffmpeg(inputStream)
        .inputFormat(inputFormat)
        .videoCodec('libx264')
        .outputFormat(outputFormat)
        .outputOptions(['-preset veryfast', '-crf 28'])
        .on('error', (err) => reject(err))
        .on('end', () => resolve(Buffer.concat(chunks)))
        .pipe();

      command.on('data', (chunk) => chunks.push(chunk));
      command.on('error', (err) => reject(err));
      command.on('end', () => resolve(Buffer.concat(chunks)));
    });
  }
}

function normalizeExtension(ext?: string, mime?: string): string {
  const raw = (ext ?? '').replace(/^\./, '').toLowerCase();
  if (raw && raw !== 'bin') return raw;
  if (!mime) return 'jpg';
  if (mime.includes('png')) return 'png';
  if (mime.includes('webp')) return 'webp';
  if (mime.includes('gif')) return 'gif';
  if (mime.includes('heic') || mime.includes('heif')) return 'heic';
  return 'jpg';
}
