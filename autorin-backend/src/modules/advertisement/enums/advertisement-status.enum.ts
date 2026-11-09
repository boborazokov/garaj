import { registerEnumType } from '@nestjs/graphql';

export enum AdvertisementStatusEnum {
  ACTIVE = 'ACTIVE',
  PAUSED = 'PAUSED',
  EXPIRED = 'EXPIRED',
}

registerEnumType(AdvertisementStatusEnum, {
  name: 'AdvertisementStatusEnum',
});
