export type ResizeMap<T extends string = string> = Record<
  T,
  { width: number; height: number }
>;

export const RESIZE_SIZES = {
  banner: {
    card: {
      width: 400,
      height: 200,
    },
    original: {
      width: 800,
      height: 400,
    },
  },

  userAvatar: {
    card: {
      width: 80,
      height: 80,
    },
    original: {
      width: 200,
      height: 200,
    },
  },

  categoryIcon: {
    card: {
      width: 80,
      height: 80,
    },
    original: {
      width: 200,
      height: 200,
    },
  },
};

/** Defaults for Sharp image pipeline (upload → MinIO). */
export const IMAGE_COMPRESS = {
  maxEdge: {
    default: 1920,
    workshop: 1920,
    part: 1920,
    order: 1600,
    service: 1920,
    avatar: 512,
    categoryIcon: 256,
    banner: 1200,
  },
  jpegQuality: 82,
  webpQuality: 80,
  pngQuality: 85,
  /** Second pass if output is still larger than input. */
  jpegQualityAggressive: 72,
} as const;
