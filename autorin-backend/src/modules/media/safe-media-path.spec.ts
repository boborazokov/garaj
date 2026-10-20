import { parsePublicMediaPath } from './safe-media-path';

describe('parsePublicMediaPath', () => {
  it('accepts a normal object key', () => {
    expect(parsePublicMediaPath('parts/images/photo.jpg')).toEqual({
      bucket: 'parts',
      objectKey: 'images/photo.jpg',
    });
  });

  it('rejects traversal and unknown buckets', () => {
    expect(() => parsePublicMediaPath('../etc/passwd')).toThrow();
    expect(() => parsePublicMediaPath('parts/../../secret')).toThrow();
    expect(() => parsePublicMediaPath('admin/secrets/key')).toThrow();
    expect(() => parsePublicMediaPath('parts')).toThrow();
  });
});
