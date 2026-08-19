import {
  PROMOTION_PLAN_WEIGHT,
  ServicePromotionPlanEnum,
} from 'src/modules/service/enums/service-promotion-plan.enum';
import { Workshop } from '../schema/workshop.schema';

export function isWorkshopPromotionActive(workshop: Workshop): boolean {
  return (
    workshop.isPromoted === true &&
    !!workshop.promotedUntil &&
    new Date(workshop.promotedUntil) > new Date()
  );
}

export function workshopPromotionWeight(workshop: Workshop): number {
  if (!isWorkshopPromotionActive(workshop)) return 0;
  if ((workshop.promotionPriority ?? 0) > 0) {
    return workshop.promotionPriority;
  }
  const plan = workshop.promotionPlan as ServicePromotionPlanEnum | undefined;
  return plan ? (PROMOTION_PLAN_WEIGHT[plan] ?? 1) : 1;
}
