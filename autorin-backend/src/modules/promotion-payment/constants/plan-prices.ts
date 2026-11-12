import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';

/**
 * UZS price per promotion plan. Swap for a gateway catalog / admin settings
 * when Payme / Click (or similar) is wired.
 */
export const PROMOTION_PLAN_PRICES_UZS: Record<
  ServicePromotionPlanEnum,
  number
> = {
  [ServicePromotionPlanEnum.BASIC]: 1_000,
  [ServicePromotionPlanEnum.STANDARD]: 5_000,
  [ServicePromotionPlanEnum.PREMIUM]: 10_000,
  [ServicePromotionPlanEnum.VIP]: 20_000,
  [ServicePromotionPlanEnum.TOP]: 30_000,
};
