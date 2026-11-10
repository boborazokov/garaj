import { registerEnumType } from '@nestjs/graphql';

export enum AdvertisementStatusEnum {
  ACTIVE = 'ACTIVE',
  PAUSED = 'PAUSED',
  EXPIRED = 'EXPIRED',
  /** Waiting for a free slot on this placement (max live slots). */
  QUEUED = 'QUEUED',
}

registerEnumType(AdvertisementStatusEnum, {
  name: 'AdvertisementStatusEnum',
});
