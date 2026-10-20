import { tmpdir } from 'os';
import { join } from 'path';
import { Client } from 'minio';
import { randomUUID } from 'crypto';
import { extname, basename } from 'path';
import { ConfigService } from '@nestjs/config';
import { Catalog } from 'src/constants';
import { Inject, Injectable } from '@nestjs/common';
import { ReadStreamOptions } from 'graphql-upload-ts';
import { unlinkSync, ReadStream, writeFileSync, createReadStream } from 'fs';

import { parsePublicMediaPath } from '../../modules/media/safe-media-path';
import { MINIO_CLIENT_TOKEN } from './minio.provider';
import { CompressorService } from 'src/utils/compressor';
import { GetFileArgs, UploadFileArgs, PrepareFileArgs } from './args';

@Injectable()
export class MinioService {
  constructor(
    private configService: ConfigService,
    private compressorService: CompressorService,
    @Inject(MINIO_CLIENT_TOKEN) private minioClient: Client,
  ) {}

  bufferToFileUpload(buffer: Buffer, filename: string, mimetype = 'image/png') {
    const tmpPath = join(tmpdir(), `${randomUUID()}-${filename}`);
    writeFileSync(tmpPath, buffer);

    return {
      mimetype,
      filename,
      encoding: '7bit',
      fieldName: 'file',
      createReadStream: (options?: ReadStreamOptions): ReadStream => {
        const stream = createReadStream(tmpPath, options);
        stream.on('close', () => {
          try {
            unlinkSync(tmpPath);
          } catch (error) {}
        });
        return stream;
      },
    };
  }

  streamToBuffer(
    stream: NodeJS.ReadableStream,
  ): Promise<Buffer<ArrayBufferLike>> {
    return new Promise((resolve, reject) => {
      const chunks: Buffer<ArrayBufferLike>[] = [];

      stream.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
      stream.on('end', () => resolve(Buffer.concat(chunks)));
      stream.on('error', (err) => reject(err as Error));
    });
  }

  async createBucketIfNotExists(bucketName: string) {
    try {
      const exists = await this.minioClient.bucketExists(bucketName);

      if (!exists) {
        const REGION = this.configService.get('MINIO_REGION');
        await this.minioClient.makeBucket(bucketName, REGION);
      }

      const policy = JSON.stringify({
        Version: '2012-10-17',
        Statement: [
          {
            Principal: '*',
            Effect: 'Allow',
            Action: 's3:GetObject',
            Resource: `arn:aws:s3:::${bucketName}/*`,
          },
        ],
      });

      await this.minioClient.setBucketPolicy(bucketName, policy);
    } catch (err) {
      console.error(`Error creating bucket or setting policy: ${err}`);
    }
  }

  async initializeBuckets() {
    for (const catalog of Object.values(Catalog)) {
      const [bucketName] = catalog.split('/');
      await this.createBucketIfNotExists(bucketName);
    }
  }

  async prepareFile({
    file,
    compress = true,
  }: PrepareFileArgs): Promise<Omit<UploadFileArgs, 'fileId' | 'catalog'>> {
    const fileBuffer = await this.streamToBuffer(file.createReadStream());
    const fileExtension = extname(file.filename).slice(1);
    const fileId = randomUUID();
    const fileKey = `${fileId}.${fileExtension}`;

    return {
      fileKey,
      compress,
      fileBuffer,
      fileMimetype: file.mimetype,
    };
  }

  async uploadFile({
    fileId,
    catalog,
    fileKey,
    compress,
    fileBuffer,
    fileMimetype,
  }: UploadFileArgs): Promise<string> {
    const [bucket, catalogPath] = catalog.split('/');

    if (fileId) {
      try {
        await this.minioClient.removeObject(bucket, `${catalogPath}/${fileId}`);
      } catch (error) {
        console.warn(`Warning: failed to remove old file: ${error.message}`);
      }
    }

    let finalFileKey = fileKey;
    let contentType = fileMimetype;

    if (compress) {
      const extFromKey = extname(fileKey).slice(1).toLowerCase();
      const compressedFile = await this.compressorService.compressFile(
        fileBuffer,
        contentType,
        { fileExtension: extFromKey, catalog },
      );
      fileBuffer = compressedFile.fileBuffer;
      contentType = compressedFile.mimeType;
      finalFileKey =
        basename(fileKey, extname(fileKey)) + compressedFile.fileExtension;
    }

    await this.minioClient.putObject(
      bucket,
      `${catalogPath}/${finalFileKey}`,
      fileBuffer,
      fileBuffer.length,
      { 'Content-Type': contentType },
    );

    return this.getFilePath({ bucket, catalog, fileId: finalFileKey });
  }

  /**
   * Streams an object stored as `{bucket}/{objectKey}` (e.g. categories/icons/uuid.png).
   */
  async openStoragePath(storagePath: string): Promise<{
    stream: NodeJS.ReadableStream;
    contentType: string;
  }> {
    const { bucket, objectKey } = parsePublicMediaPath(storagePath);
    const stream = await this.minioClient.getObject(bucket, objectKey);

    let contentType = 'application/octet-stream';
    try {
      const stat = await this.minioClient.statObject(bucket, objectKey);
      const metaType = stat.metaData?.['content-type'];
      if (metaType) {
        contentType = metaType;
      }
    } catch {
      /* use extension fallback */
    }

    if (contentType === 'application/octet-stream') {
      const ext = objectKey.split('.').pop()?.toLowerCase();
      if (ext === 'jpg' || ext === 'jpeg') contentType = 'image/jpeg';
      else if (ext === 'png') contentType = 'image/png';
      else if (ext === 'webp') contentType = 'image/webp';
      else if (ext === 'gif') contentType = 'image/gif';
    }

    return { stream, contentType };
  }

  async getFile({ fileId, bucket, catalog }: GetFileArgs): Promise<Buffer> {
    try {
      const stream = await this.minioClient.getObject(
        bucket,
        `${catalog}/${fileId}`,
      );
      return await this.streamToBuffer(stream);
    } catch (err) {
      console.error(`Error getting file: ${err.message}`);
      throw err;
    }
  }

  async deleteFile({ fileId, bucket, catalog }: GetFileArgs): Promise<void> {
    try {
      await this.minioClient.removeObject(bucket, `${catalog}/${fileId}`);
    } catch (err) {
      console.error(`Error deleting file: ${err.message}`);
    }
  }

  async deleteFileFromUrl(fileUrl: string): Promise<void> {
    const { fileId, bucket, catalog } = this.parseFileUrl(fileUrl);
    await this.deleteFile({ fileId, bucket, catalog });
  }

  async deleteFilesFromUrls(files: string[], indexes: number[]) {
    const { deletedFiles, filteredFiles } = files.reduce<{
      deletedFiles: string[];
      filteredFiles: string[];
    }>(
      (acc, file, index) => {
        if (indexes.includes(index)) {
          acc.deletedFiles.push(file);
        } else {
          acc.filteredFiles.push(file);
        }
        return acc;
      },
      {
        deletedFiles: [],
        filteredFiles: [],
      },
    );

    if (!deletedFiles.length) return { filteredFiles, deletedFiles: [] };

    await Promise.all(
      deletedFiles.map((fileUrl) => {
        return this.deleteFileFromUrl(fileUrl);
      }),
    );

    return { deletedFiles, filteredFiles };
  }

  getFilePath({ fileId, catalog }: GetFileArgs): string {
    return `${catalog}/${fileId}`;
  }

  parseFileUrl(fileUrl: string) {
    try {
      const parts = fileUrl.split('/');

      if (parts.length < 2) {
        throw new Error('URL must contain at least a catalog and a fileId');
      }

      const fileId = parts.pop()!;
      const catalog = parts.join('/') as Catalog;
      const bucket = parts.shift()!;

      return { fileId, bucket, catalog };
    } catch (err) {
      throw new Error(`Invalid file URL: ${fileUrl}. ${err.message}`);
    }
  }
}
