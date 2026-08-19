import * as dayjs from 'dayjs';
import {
  PROMOTION_PLAN_DAYS,
  PROMOTION_PLAN_WEIGHT,
  ServicePromotionPlanEnum,
} from '../enums/service-promotion-plan.enum';
import { AutoService } from '../schema/service.schema';

export function isServicePromotionActive(service: AutoService): boolean {
  return (
    service.isPromoted === true &&
    !!service.promotedUntil &&
    new Date(service.promotedUntil) > new Date()
  );
}

export function servicePromotionWeight(service: AutoService): number {
  if (!isServicePromotionActive(service)) return 0;
  if (service.promotionPriority > 0) return service.promotionPriority;
  const plan = service.promotionPlan as ServicePromotionPlanEnum | undefined;
  return plan ? (PROMOTION_PLAN_WEIGHT[plan] ?? 1) : 1;
}

export function promotionDaysForPlan(plan: ServicePromotionPlanEnum): number {
  return PROMOTION_PLAN_DAYS[plan] ?? 7;
}

export function promotionPriorityForPlan(plan: ServicePromotionPlanEnum): number {
  return PROMOTION_PLAN_WEIGHT[plan] ?? 1;
}

export function buildPromotionUpdate(plan: ServicePromotionPlanEnum) {
  const days = promotionDaysForPlan(plan);
  const promotedUntil = dayjs().add(days, 'day').toDate();
  return {
    isPromoted: true,
    promotedUntil,
    promotionPlan: plan,
    promotionPriority: promotionPriorityForPlan(plan),
  };
}
