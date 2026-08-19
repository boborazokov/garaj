import { BadRequestException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { extname } from 'path';

/** Extensions that must never be stored or served as user uploads. */
export const BLOCKED_UPLOAD_EXTENSIONS = new Set([
  'exe',
  'js',
  'mjs',
  'cjs',
  'html',
  'htm',
  'svg',
  'sh',
  'bash',
  'php',
  'phtml',
  'bat',
  'cmd',
  'ps1',
  'vbs',
  'jar',
  'msi',
  'dll',
  'com',
]);

/** Allowed image/media types for catalog uploads (parts, workshops, reviews). */
export const ALLOWED_UPLOAD_MIME_TYPES = new Set([
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/heic',
  'image/heif',
  'image/pjpeg',
]);

/** Allowed voice message types for the chat. */
export const ALLOWED_VOICE_MIME_TYPES = new Set([
  'audio/mpeg',
  'audio/mp3',
  'audio/mp4',
  'audio/aac',
  'audio/x-m4a',
  'audio/m4a',
  'audio/ogg',
  'audio/webm',
  'audio/wav',
  'audio/x-wav',
]);

const VOICE_MIME_TO_EXT: Record<string, string> = {
  'audio/mpeg': 'mp3',
  'audio/mp3': 'mp3',
  'audio/mp4': 'm4a',
  'audio/aac': 'aac',
  'audio/m4a': 'm4a',
  'audio/x-m4a': 'm4a',
  'audio/ogg': 'ogg',
  'audio/webm': 'webm',
  'audio/wav': 'wav',
  'audio/x-wav': 'wav',
};

export function assertVoiceUploadAllowed(
  file: Express.Multer.File,
  maxBytes: number,
): void {
  if (!file?.buffer?.length) {
    throw new BadRequestException('Empty upload');
  }
  if (file.size > maxBytes || file.buffer.length > maxBytes) {
    throw new BadRequestException(
      `Voice file exceeds maximum size of ${maxBytes} bytes`,
    );
  }
  const mime = (file.mimetype ?? '').toLowerCase();
  if (!ALLOWED_VOICE_MIME_TYPES.has(mime)) {
    throw new BadRequestException('Voice MIME type is not allowed');
  }
}

export function secureVoiceUploadKey(
  mime: string,
): { fileKey: string; extension: string } {
  const ext = VOICE_MIME_TO_EXT[mime.toLowerCase()] ?? 'bin';
  return { fileKey: randomUUID(), extension: ext };
}

const EXT_TO_MIME: Record<string, string> = {
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  webp: 'image/webp',
  gif: 'image/gif',
  heic: 'image/heic',
  heif: 'image/heif',
};

const MIME_TO_EXT: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/pjpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/gif': 'gif',
  'image/heic': 'heic',
  'image/heif': 'heif',
};

export function normalizeExtension(originalName: string): string {
  const ext = extname(originalName).replace(/^\./, '').toLowerCase();
  return ext;
}

export function assertUploadAllowed(
  file: Express.Multer.File,
  maxBytes: number,
): void {
  if (!file?.buffer?.length) {
    throw new BadRequestException('Empty upload');
  }

  if (file.size > maxBytes || file.buffer.length > maxBytes) {
    throw new BadRequestException(
      `File exceeds maximum size of ${maxBytes} bytes`,
    );
  }

  const ext = normalizeExtension(file.originalname);
  if (!ext || BLOCKED_UPLOAD_EXTENSIONS.has(ext)) {
    throw new BadRequestException('File type is not allowed');
  }

  let mime = (file.mimetype ?? '').toLowerCase();
  if (!ALLOWED_UPLOAD_MIME_TYPES.has(mime)) {
    const inferred = EXT_TO_MIME[ext];
    if (
      (mime === 'application/octet-stream' || mime === '') &&
      inferred &&
      ALLOWED_UPLOAD_MIME_TYPES.has(inferred)
    ) {
      mime = inferred;
    } else {
      throw new BadRequestException('MIME type is not allowed');
    }
  }

  const expectedExt = MIME_TO_EXT[mime];
  if (expectedExt && ext !== expectedExt && ext !== 'jpg' && expectedExt !== 'jpg') {
    throw new BadRequestException('File extension does not match content type');
  }
}

/** Opaque object key — never use the client-provided filename as storage key. */
export function secureUploadKey(mime: string): { fileKey: string; extension: string } {
  const extension = MIME_TO_EXT[mime.toLowerCase()] ?? 'bin';
  return { fileKey: randomUUID(), extension };
}

export function validateUploadBatch(
  files: Express.Multer.File[],
  maxBytes: number,
  maxFiles = 10,
): void {
  if (!files?.length) {
    throw new BadRequestException('No files provided');
  }
  if (files.length > maxFiles) {
    throw new BadRequestException(`Maximum ${maxFiles} files per request`);
  }
  for (const file of files) {
    assertUploadAllowed(file, maxBytes);
  }
}
