import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementPlanEnum } from '../enums/advertisement-plan.enum';

/**
 * Banner tariff matrix (UZS) — placement × duration.
 *
 * Anchored to existing product-boost prices:
 *   BASIC 15k / 3d → STANDARD 35k / 7d → … → TOP 200k / 45d
 *
 * Banner inventory is platform-wide, so weekly BRAND sits near TOP,
 * then steps down by surface reach. Longer plans get ~25% volume discount
 * vs linear week multiples.
 */
export const ADVERTISEMENT_PLAN_PRICES_UZS: Record<
  CategoryTypeEnum,
  Record<AdvertisementPlanEnum, number>
> = {
  /** Home — top carousel (highest reach). */
  [CategoryTypeEnum.BRAND]: {
    [AdvertisementPlanEnum.DAY]: 35_000,
    [AdvertisementPlanEnum.WEEK]: 180_000,
    [AdvertisementPlanEnum.MONTH]: 540_000,
    [AdvertisementPlanEnum.QUARTER]: 1_350_000,
  },
  /** Products — category / search / home product block. */
  [CategoryTypeEnum.PART]: {
    [AdvertisementPlanEnum.DAY]: 25_000,
    [AdvertisementPlanEnum.WEEK]: 120_000,
    [AdvertisementPlanEnum.MONTH]: 360_000,
    [AdvertisementPlanEnum.QUARTER]: 900_000,
  },
  /** Services hub + in-feed slots. */
  [CategoryTypeEnum.SERVICE]: {
    [AdvertisementPlanEnum.DAY]: 28_000,
    [AdvertisementPlanEnum.WEEK]: 140_000,
    [AdvertisementPlanEnum.MONTH]: 420_000,
    [AdvertisementPlanEnum.QUARTER]: 1_050_000,
  },
  /** Requests / orders feed. */
  [CategoryTypeEnum.ANNOUNCEMENT]: {
    [AdvertisementPlanEnum.DAY]: 22_000,
    [AdvertisementPlanEnum.WEEK]: 100_000,
    [AdvertisementPlanEnum.MONTH]: 300_000,
    [AdvertisementPlanEnum.QUARTER]: 750_000,
  },
  /** Search explore / catalog. */
  [CategoryTypeEnum.TUNING]: {
    [AdvertisementPlanEnum.DAY]: 18_000,
    [AdvertisementPlanEnum.WEEK]: 85_000,
    [AdvertisementPlanEnum.MONTH]: 255_000,
    [AdvertisementPlanEnum.QUARTER]: 640_000,
  },
  /** Public seller / store page. */
  [CategoryTypeEnum.MODEL]: {
    [AdvertisementPlanEnum.DAY]: 15_000,
    [AdvertisementPlanEnum.WEEK]: 70_000,
    [AdvertisementPlanEnum.MONTH]: 210_000,
    [AdvertisementPlanEnum.QUARTER]: 520_000,
  },
};

/** Placement priority for catalog ordering (home first). */
export const ADVERTISEMENT_PLACEMENT_WEIGHT: Record<CategoryTypeEnum, number> = {
  [CategoryTypeEnum.BRAND]: 6,
  [CategoryTypeEnum.PART]: 5,
  [CategoryTypeEnum.SERVICE]: 4,
  [CategoryTypeEnum.ANNOUNCEMENT]: 3,
  [CategoryTypeEnum.TUNING]: 2,
  [CategoryTypeEnum.MODEL]: 1,
};
