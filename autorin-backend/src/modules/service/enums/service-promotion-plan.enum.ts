import { registerEnumType } from '@nestjs/graphql';

/** Paid boost tiers — higher plan = higher sort priority in discovery. */
export enum ServicePromotionPlanEnum {
  BASIC = 'BASIC',
  STANDARD = 'STANDARD',
  PREMIUM = 'PREMIUM',
  VIP = 'VIP',
}

registerEnumType(ServicePromotionPlanEnum, {
  name: 'ServicePromotionPlanEnum',
});

/** Days granted per plan when a seller purchases promotion. */
export const PROMOTION_PLAN_DAYS: Record<ServicePromotionPlanEnum, number> = {
  [ServicePromotionPlanEnum.BASIC]: 3,
  [ServicePromotionPlanEnum.STANDARD]: 7,
  [ServicePromotionPlanEnum.PREMIUM]: 14,
  [ServicePromotionPlanEnum.VIP]: 30,
};

/** Sort weight — VIP surfaces above PREMIUM, etc. */
export const PROMOTION_PLAN_WEIGHT: Record<ServicePromotionPlanEnum, number> = {
  [ServicePromotionPlanEnum.BASIC]: 1,
  [ServicePromotionPlanEnum.STANDARD]: 2,
  [ServicePromotionPlanEnum.PREMIUM]: 3,
  [ServicePromotionPlanEnum.VIP]: 4,
};
