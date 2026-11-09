import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';

/**
 * UZS price per promotion plan. Swap for a gateway catalog / admin settings
 * when Payme / Click (or similar) is wired.
 */
export const PROMOTION_PLAN_PRICES_UZS: Record<
  ServicePromotionPlanEnum,
  number
> = {
  [ServicePromotionPlanEnum.BASIC]: 15_000,
  [ServicePromotionPlanEnum.STANDARD]: 35_000,
  [ServicePromotionPlanEnum.PREMIUM]: 70_000,
  [ServicePromotionPlanEnum.VIP]: 120_000,
  [ServicePromotionPlanEnum.TOP]: 200_000,
};
