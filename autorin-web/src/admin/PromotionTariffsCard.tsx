import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { RotateCcw, Save } from "lucide-react";
import {
  PROMOTION_PLAN_PRICES,
  RESET_PROMOTION_TARIFFS,
  SET_PROMOTION_TARIFFS,
} from "@/graphql/operations";
import type { PromotionPlan, PromotionPlanPrice } from "@/types";

const PLAN_ORDER: PromotionPlan[] = [
  "BASIC",
  "STANDARD",
  "PREMIUM",
  "VIP",
  "TOP",
];

const PLAN_LABELS: Record<PromotionPlan, string> = {
  BASIC: "Asosiy / BASIC",
  STANDARD: "Standart / STANDARD",
  PREMIUM: "Premium / PREMIUM",
  VIP: "VIP",
  TOP: "TOP",
};

const FALLBACK: Record<PromotionPlan, number> = {
  BASIC: 15_000,
  STANDARD: 35_000,
  PREMIUM: 70_000,
  VIP: 120_000,
  TOP: 200_000,
};

export function PromotionTariffsCard() {
  const { data, loading, refetch } = useQuery<{
    promotionPlanPrices: PromotionPlanPrice[];
  }>(PROMOTION_PLAN_PRICES, { fetchPolicy: "cache-and-network" });

  const baseline = useMemo(() => {
    const map = { ...FALLBACK };
    for (const row of data?.promotionPlanPrices ?? []) {
      map[row.plan] = row.amount;
    }
    return map;
  }, [data]);

  const daysByPlan = useMemo(() => {
    const map: Partial<Record<PromotionPlan, number>> = {};
    for (const row of data?.promotionPlanPrices ?? []) {
      map[row.plan] = row.days;
    }
    return map;
  }, [data]);

  const [draft, setDraft] = useState(baseline);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setDraft(baseline);
    setError(null);
  }, [baseline]);

  const dirty = PLAN_ORDER.some((plan) => draft[plan] !== baseline[plan]);

  const [saveTariffs, { loading: saving }] = useMutation(SET_PROMOTION_TARIFFS);
  const [resetTariffs, { loading: resetting }] = useMutation(
    RESET_PROMOTION_TARIFFS,
  );
  const busy = loading || saving || resetting;

  return (
    <div className="rounded-2xl border border-carbon-600 bg-carbon-800 p-6">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="font-semibold text-white">Product Top тарифы</h2>
          <p className="mt-2 text-sm text-carbon-100">
            Цены «Поднять в топ» для товаров / заказов / сервисов в приложении
            (BASIC…TOP). Суммы в UZS. Также на странице Товары.
          </p>
        </div>
        <div className="flex gap-2">
          <button
            type="button"
            disabled={busy}
            onClick={async () => {
              setError(null);
              try {
                await resetTariffs();
                await refetch();
              } catch (err) {
                setError(
                  err instanceof Error ? err.message : "Не удалось сбросить",
                );
              }
            }}
            className="inline-flex h-9 items-center gap-1.5 rounded-xl border border-carbon-600 px-3 text-sm text-white disabled:opacity-60"
          >
            <RotateCcw className="size-3.5" />
            Сбросить
          </button>
          <button
            type="button"
            disabled={busy || !dirty}
            onClick={async () => {
              setError(null);
              try {
                await saveTariffs({
                  variables: {
                    rows: PLAN_ORDER.map((plan) => ({
                      plan,
                      amount: draft[plan],
                    })),
                  },
                });
                await refetch();
              } catch (err) {
                setError(
                  err instanceof Error ? err.message : "Не удалось сохранить",
                );
              }
            }}
            className="inline-flex h-9 items-center gap-1.5 rounded-xl bg-amber-500 px-3 text-sm font-semibold text-white disabled:opacity-60"
          >
            <Save className="size-3.5" />
            {saving ? "Сохранение…" : "Сохранить"}
          </button>
        </div>
      </div>

      {error ? (
        <p className="mt-3 text-sm text-red-400">{error}</p>
      ) : null}

      <div className="mt-5 overflow-x-auto">
        <table className="w-full border-collapse text-sm">
          <thead>
            <tr className="text-left text-carbon-100">
              <th className="pb-2 pr-3 font-medium">План</th>
              <th className="pb-2 pr-3 font-medium">Дней</th>
              <th className="pb-2 font-medium">Цена (UZS)</th>
            </tr>
          </thead>
          <tbody>
            {PLAN_ORDER.map((plan) => (
              <tr key={plan} className="border-t border-carbon-600">
                <td className="py-2.5 pr-3 text-white">{PLAN_LABELS[plan]}</td>
                <td className="py-2.5 pr-3 text-carbon-100">
                  {daysByPlan[plan] ?? "—"}
                </td>
                <td className="py-2.5">
                  <input
                    type="text"
                    inputMode="numeric"
                    disabled={busy}
                    value={draft[plan]}
                    onChange={(event) => {
                      const digits = event.target.value.replace(/[^\d]/g, "");
                      const amount = digits === "" ? 0 : Number(digits);
                      setDraft((prev) => ({
                        ...prev,
                        [plan]: Number.isFinite(amount) ? amount : 0,
                      }));
                    }}
                    className="h-9 w-32 rounded-xl border border-carbon-600 bg-carbon-900 px-3 text-right text-white disabled:opacity-60"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
