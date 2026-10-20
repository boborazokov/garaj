import { Bucket } from '../../constants/buckets.constants';

const ALLOWED_BUCKETS = new Set<string>(Object.values(Bucket));

/** Reject path traversal and buckets this API does not serve. */
export function parsePublicMediaPath(storagePath: string): {
  bucket: string;
  objectKey: string;
} {
  const raw = storagePath.replace(/^\//, '');
  if (
    !raw ||
    raw.includes('..') ||
    raw.includes('\\') ||
    raw.includes('\0') ||
    raw.includes('%')
  ) {
    throw new Error('Invalid storage path');
  }

  const segments = raw.split('/').filter(Boolean);
  if (segments.length < 2) {
    throw new Error('Invalid storage path');
  }

  const bucket = segments[0];
  if (!ALLOWED_BUCKETS.has(bucket)) {
    throw new Error('Invalid storage path');
  }

  return { bucket, objectKey: segments.slice(1).join('/') };
}
