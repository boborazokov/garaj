import type { PromotionPlan, PromotionPlanPrice } from "@/types";
import {
  DEFAULT_AMOUNTS,
  DEFAULT_DAYS,
  TOP_PLAN_ORDER,
} from "./constants";
import type { TariffFormState } from "./types";

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

export function availablePlans(
  rows: PromotionPlanPrice[],
  editingPlan?: PromotionPlan | null,
): PromotionPlan[] {
  // All enum plans stay visible; "create" edits a selected plan's overrides.
  if (editingPlan) return [editingPlan];
  return TOP_PLAN_ORDER.filter((plan) =>
    rows.some((row) => row.plan === plan),
  );
}

export function formatUzs(amount: number): string {
  return `${amount.toLocaleString("uz-UZ")} UZS`;
}
