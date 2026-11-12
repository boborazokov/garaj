import type { PromotionPlan, PromotionPlanPrice } from "@/types";
import {
  DEFAULT_AMOUNTS,
  DEFAULT_DAYS,
  TOP_PLAN_ORDER,
} from "./constants";
import type { TariffFormState, TariffPlanOption } from "./types";

export function emptyTariffForm(plan: PromotionPlan = "BASIC"): TariffFormState {
  return {
    plan,
    baseAmount: DEFAULT_AMOUNTS[plan],
    days: DEFAULT_DAYS[plan],
    discountPercent: 0,
  };
}

export function formFromRow(row: PromotionPlanPrice): TariffFormState {
  const discount = Math.max(0, Math.min(100, row.discountPercent ?? 0));
  const baseAmount =
    discount > 0 && discount < 100
      ? Math.round(row.amount / (1 - discount / 100))
      : row.amount;
  return {
    plan: row.plan,
    baseAmount,
    days: row.days,
    discountPercent: discount,
  };
}

export function finalAmount(form: TariffFormState): number {
  const discount = Math.max(0, Math.min(100, form.discountPercent));
  const base = Math.max(0, form.baseAmount);
  return Math.round(base * (1 - discount / 100));
}

export function buildPlanOptions(rows: PromotionPlanPrice[]): TariffPlanOption[] {
  return TOP_PLAN_ORDER.map((plan) => {
    const row = rows.find((item) => item.plan === plan);
    return {
      plan,
      days: row?.days ?? DEFAULT_DAYS[plan],
      amount: row?.amount ?? DEFAULT_AMOUNTS[plan],
      discountPercent: row?.discountPercent ?? 0,
    };
  });
}

export function formatUzs(amount: number): string {
  return `${amount.toLocaleString("uz-UZ")} UZS`;
}
