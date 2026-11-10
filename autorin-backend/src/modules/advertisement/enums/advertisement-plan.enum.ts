import { registerEnumType } from '@nestjs/graphql';

/**
 * Paid banner duration tiers. Days align with admin duration presets
 * (1d / 7d / 30d / 90d) used when creating campaigns.
 */
export enum AdvertisementPlanEnum {
  DAY = 'DAY',
  WEEK = 'WEEK',
  MONTH = 'MONTH',
  QUARTER = 'QUARTER',
}

registerEnumType(AdvertisementPlanEnum, {
  name: 'AdvertisementPlanEnum',
});

export const ADVERTISEMENT_PLAN_DAYS: Record<AdvertisementPlanEnum, number> = {
  [AdvertisementPlanEnum.DAY]: 1,
  [AdvertisementPlanEnum.WEEK]: 7,
  [AdvertisementPlanEnum.MONTH]: 30,
  [AdvertisementPlanEnum.QUARTER]: 90,
};

/** Higher = more prominent inventory (used for sorting tariff catalogs). */
export const ADVERTISEMENT_PLAN_WEIGHT: Record<AdvertisementPlanEnum, number> = {
  [AdvertisementPlanEnum.DAY]: 1,
  [AdvertisementPlanEnum.WEEK]: 2,
  [AdvertisementPlanEnum.MONTH]: 3,
  [AdvertisementPlanEnum.QUARTER]: 4,
};
