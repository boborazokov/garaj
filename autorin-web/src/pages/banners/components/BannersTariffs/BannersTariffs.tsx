import { useEffect, useMemo, useState } from "react";
import { useMutation } from "@apollo/client/react";
import { RotateCcw, Save } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  RESET_ADVERTISEMENT_TARIFFS,
  SET_ADVERTISEMENT_TARIFFS,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { AdvertisementPlanPrice, CategoryType } from "@/types";
import {
  BANNERS_TEXTS,
  FALLBACK_AD_PRICES_UZS,
  PLAN_COLUMN_ORDER,
  PLAN_LABELS,
  PLACEMENT_LABELS,
  PLACEMENT_TYPES,
  type AdvertisementPlanId,
} from "../../constants";
import type { BannersTariffsProps } from "../../types";
import "./banners-tariffs.css";

type DraftMap = Record<CategoryType, Record<AdvertisementPlanId, number>>;

function buildDraft(prices?: AdvertisementPlanPrice[]): DraftMap {
  const draft = {} as DraftMap;
  for (const placement of PLACEMENT_TYPES) {
    draft[placement] = { ...FALLBACK_AD_PRICES_UZS[placement] };
  }
  for (const row of prices ?? []) {
    if (!draft[row.placement]) continue;
    draft[row.placement][row.plan] = row.amount;
  }
  return draft;
}

function draftsEqual(a: DraftMap, b: DraftMap): boolean {
  for (const placement of PLACEMENT_TYPES) {
    for (const plan of PLAN_COLUMN_ORDER) {
      if (a[placement][plan] !== b[placement][plan]) return false;
    }
  }
  return true;
}

export function BannersTariffs({
  prices,
  loading,
  onSaved,
}: BannersTariffsProps) {
  const { t } = useLanguage();
  const baseline = useMemo(() => buildDraft(prices), [prices]);
  const [draft, setDraft] = useState<DraftMap>(baseline);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setDraft(baseline);
    setError(null);
  }, [baseline]);

  const dirty = !draftsEqual(draft, baseline);

  const [saveTariffs, { loading: saving }] = useMutation<{
    setAdvertisementTariffs: AdvertisementPlanPrice[];
  }>(SET_ADVERTISEMENT_TARIFFS);

  const [resetTariffs, { loading: resetting }] = useMutation<{
    resetAdvertisementTariffs: AdvertisementPlanPrice[];
  }>(RESET_ADVERTISEMENT_TARIFFS);

  const busy = saving || resetting || Boolean(loading);

  const onChange = (
    placement: CategoryType,
    plan: AdvertisementPlanId,
    raw: string,
  ) => {
    const digits = raw.replace(/[^\d]/g, "");
    const amount = digits === "" ? 0 : Number(digits);
    setDraft((prev) => ({
      ...prev,
      [placement]: {
        ...prev[placement],
        [plan]: Number.isFinite(amount) ? amount : 0,
      },
    }));
  };

  const handleSave = async () => {
    setError(null);
    const rows = PLACEMENT_TYPES.flatMap((placement) =>
      PLAN_COLUMN_ORDER.map((plan) => ({
        placement,
        plan,
        amount: draft[placement][plan],
      })),
    );
    try {
      const result = await saveTariffs({ variables: { rows } });
      onSaved?.(result.data?.setAdvertisementTariffs);
    } catch (err) {
      setError(err instanceof Error ? err.message : t(BANNERS_TEXTS.tariffsSaveError));
    }
  };

  const handleReset = async () => {
    setError(null);
    try {
      const result = await resetTariffs();
      onSaved?.(result.data?.resetAdvertisementTariffs);
    } catch (err) {
      setError(err instanceof Error ? err.message : t(BANNERS_TEXTS.tariffsSaveError));
    }
  };

  return (
    <section className="banners-tariffs overflow-hidden rounded-[10px] border border-border bg-card">
      <div className="flex flex-wrap items-start justify-between gap-3 border-b border-border px-3.5 py-3">
        <div className="min-w-0">
          <h2 className="m-0 text-[14px] font-semibold text-foreground">
            {t(BANNERS_TEXTS.tariffsTitle)}
          </h2>
          <p className="mt-1 mb-0 text-[12px] text-muted-foreground">
            {t(BANNERS_TEXTS.tariffsSubtitle)}
          </p>
        </div>
        <div className="flex shrink-0 items-center gap-2">
          <Button
            type="button"
            variant="outline"
            className="h-9"
            disabled={busy}
            onClick={handleReset}
          >
            <RotateCcw className="size-3.5" />
            {t(BANNERS_TEXTS.tariffsReset)}
          </Button>
          <Button
            type="button"
            className="h-9"
            disabled={busy || !dirty}
            onClick={handleSave}
          >
            <Save className="size-3.5" />
            {busy && saving
              ? t(BANNERS_TEXTS.saving)
              : t(BANNERS_TEXTS.tariffsSave)}
          </Button>
        </div>
      </div>
      {error ? (
        <p className="m-0 border-b border-border px-3.5 py-2 text-[12px] text-red-600">
          {error}
        </p>
      ) : null}
      <div className="overflow-x-auto">
        <table className="banners-tariffs__table">
          <thead>
            <tr>
              <th>{t(BANNERS_TEXTS.placementFilter)}</th>
              {PLAN_COLUMN_ORDER.map((plan) => (
                <th key={plan}>{t(PLAN_LABELS[plan])}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {PLACEMENT_TYPES.map((placement) => (
              <tr key={placement}>
                <td className="banners-tariffs__placement">
                  {t(PLACEMENT_LABELS[placement])}
                </td>
                {PLAN_COLUMN_ORDER.map((plan) => (
                  <td key={plan}>
                    <input
                      type="text"
                      inputMode="numeric"
                      className="banners-tariffs__input"
                      disabled={busy}
                      value={draft[placement][plan]}
                      onChange={(event) =>
                        onChange(placement, plan, event.target.value)
                      }
                      aria-label={`${placement} ${plan}`}
                    />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
