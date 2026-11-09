import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { RotateCcw, Save } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  PROMOTION_PLAN_PRICES,
  RESET_PROMOTION_TARIFFS,
  SET_PROMOTION_TARIFFS,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { PromotionPlan, PromotionPlanPrice } from "@/types";
import { PRODUCTS_TEXTS, TOP_PLAN_LABELS, TOP_PLAN_ORDER } from "../../constants";
import "./products-top-tariffs.css";

const FALLBACK: Record<PromotionPlan, number> = {
  BASIC: 15_000,
  STANDARD: 35_000,
  PREMIUM: 70_000,
  VIP: 120_000,
  TOP: 200_000,
};

export function ProductsTopTariffs() {
  const { t } = useLanguage();
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

  const dirty = TOP_PLAN_ORDER.some((plan) => draft[plan] !== baseline[plan]);

  const [saveTariffs, { loading: saving }] = useMutation(SET_PROMOTION_TARIFFS);
  const [resetTariffs, { loading: resetting }] = useMutation(
    RESET_PROMOTION_TARIFFS,
  );
  const busy = loading || saving || resetting;

  return (
    <section className="products-top-tariffs overflow-hidden rounded-[10px] border border-border bg-card">
      <div className="flex flex-wrap items-start justify-between gap-3 border-b border-border px-3.5 py-3">
        <div className="min-w-0">
          <h2 className="m-0 text-[14px] font-semibold text-foreground">
            {t(PRODUCTS_TEXTS.topTariffsTitle)}
          </h2>
          <p className="mt-1 mb-0 text-[12px] text-muted-foreground">
            {t(PRODUCTS_TEXTS.topTariffsSubtitle)}
          </p>
        </div>
        <div className="flex shrink-0 items-center gap-2">
          <Button
            type="button"
            variant="outline"
            className="h-9"
            disabled={busy}
            onClick={async () => {
              setError(null);
              try {
                await resetTariffs();
                await refetch();
              } catch (err) {
                setError(
                  err instanceof Error
                    ? err.message
                    : t(PRODUCTS_TEXTS.topTariffsError),
                );
              }
            }}
          >
            <RotateCcw className="size-3.5" />
            {t(PRODUCTS_TEXTS.topTariffsReset)}
          </Button>
          <Button
            type="button"
            className="h-9"
            disabled={busy || !dirty}
            onClick={async () => {
              setError(null);
              try {
                await saveTariffs({
                  variables: {
                    rows: TOP_PLAN_ORDER.map((plan) => ({
                      plan,
                      amount: draft[plan],
                    })),
                  },
                });
                await refetch();
              } catch (err) {
                setError(
                  err instanceof Error
                    ? err.message
                    : t(PRODUCTS_TEXTS.topTariffsError),
                );
              }
            }}
          >
            <Save className="size-3.5" />
            {saving
              ? t(PRODUCTS_TEXTS.topTariffsSaving)
              : t(PRODUCTS_TEXTS.topTariffsSave)}
          </Button>
        </div>
      </div>

      {error ? (
        <p className="m-0 border-b border-border px-3.5 py-2 text-[12px] text-red-600">
          {error}
        </p>
      ) : null}

      <div className="overflow-x-auto">
        <table className="products-top-tariffs__table">
          <thead>
            <tr>
              <th>{t(PRODUCTS_TEXTS.topTariffsPlan)}</th>
              <th>{t(PRODUCTS_TEXTS.topTariffsDays)}</th>
              <th>{t(PRODUCTS_TEXTS.topTariffsPrice)}</th>
            </tr>
          </thead>
          <tbody>
            {TOP_PLAN_ORDER.map((plan) => (
              <tr key={plan}>
                <td className="products-top-tariffs__plan">
                  {t(TOP_PLAN_LABELS[plan])}
                </td>
                <td>{daysByPlan[plan] ?? "—"}</td>
                <td>
                  <input
                    type="text"
                    inputMode="numeric"
                    className="products-top-tariffs__input"
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
                    aria-label={plan}
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
