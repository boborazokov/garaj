import { useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Plus, RotateCcw } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DELETE_PROMOTION_TARIFF,
  PROMOTION_PLAN_PRICES,
  RESET_PROMOTION_TARIFFS,
  SET_PROMOTION_TARIFF,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { PromotionPlanPrice } from "@/types";
import {
  ConfirmDialog,
  TariffFormDialog,
  TopTariffsTable,
} from "./components";
import { TOP_PLAN_ORDER, TOP_TARIFFS_TEXTS } from "./constants";
import {
  availablePlans,
  emptyTariffForm,
  finalAmount,
  formFromRow,
} from "./helpers";
import type { TariffFormState } from "./types";

export function TopTariffsPage() {
  const { t } = useLanguage();
  const { data, loading, refetch } = useQuery<{
    promotionPlanPrices: PromotionPlanPrice[];
  }>(PROMOTION_PLAN_PRICES, { fetchPolicy: "cache-and-network" });

  const rows = useMemo(() => {
    const list = data?.promotionPlanPrices ?? [];
    return [...list].sort(
      (a, b) => TOP_PLAN_ORDER.indexOf(a.plan) - TOP_PLAN_ORDER.indexOf(b.plan),
    );
  }, [data]);

  const [creating, setCreating] = useState(false);
  const [editing, setEditing] = useState<PromotionPlanPrice | null>(null);
  const [form, setForm] = useState<TariffFormState>(emptyTariffForm());
  const [error, setError] = useState<string | null>(null);
  const [pendingDelete, setPendingDelete] = useState<PromotionPlanPrice | null>(
    null,
  );
  const [pendingReset, setPendingReset] = useState(false);

  const [saveTariff, { loading: saving }] = useMutation(SET_PROMOTION_TARIFF);
  const [deleteTariff, { loading: deleting }] = useMutation(
    DELETE_PROMOTION_TARIFF,
  );
  const [resetTariffs, { loading: resetting }] = useMutation(
    RESET_PROMOTION_TARIFFS,
  );

  const busy = saving || deleting || resetting;
  const modalOpen = creating || editing !== null;

  function openCreate() {
    setEditing(null);
    setCreating(true);
    setForm(emptyTariffForm(rows[0]?.plan ?? "BASIC"));
    setError(null);
  }

  function openEdit(row: PromotionPlanPrice) {
    setCreating(false);
    setEditing(row);
    setForm(formFromRow(row));
    setError(null);
  }

  function closeModal() {
    if (busy) return;
    setCreating(false);
    setEditing(null);
    setError(null);
  }

  async function onSave() {
    if (form.days < 1 || form.days > 365) {
      setError(t(TOP_TARIFFS_TEXTS.daysHint));
      return;
    }
    setError(null);
    try {
      await saveTariff({
        variables: {
          plan: form.plan,
          amount: finalAmount(form),
          days: form.days,
          discountPercent: form.discountPercent,
        },
      });
      await refetch();
      closeModal();
    } catch (err) {
      setError(
        err instanceof Error ? err.message : t(TOP_TARIFFS_TEXTS.error),
      );
    }
  }

  async function confirmDelete() {
    if (!pendingDelete) return;
    try {
      await deleteTariff({ variables: { plan: pendingDelete.plan } });
      await refetch();
      setPendingDelete(null);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : t(TOP_TARIFFS_TEXTS.error),
      );
      setPendingDelete(null);
    }
  }

  async function confirmReset() {
    try {
      await resetTariffs();
      await refetch();
      setPendingReset(false);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : t(TOP_TARIFFS_TEXTS.error),
      );
      setPendingReset(false);
    }
  }

  return (
    <div className="flex flex-col gap-2.5">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div className="min-w-0">
          <h1 className="m-0 text-[18px] font-semibold text-foreground">
            {t(TOP_TARIFFS_TEXTS.title)}
          </h1>
          <p className="mt-1 mb-0 text-[13px] text-muted-foreground">
            {t(TOP_TARIFFS_TEXTS.subtitle)}
          </p>
        </div>
        <div className="flex shrink-0 items-center gap-2">
          <Button
            type="button"
            variant="outline"
            className="h-11"
            disabled={busy}
            onClick={() => setPendingReset(true)}
          >
            <RotateCcw className="size-3.5" />
            {t(TOP_TARIFFS_TEXTS.resetAll)}
          </Button>
          <Button
            type="button"
            className="h-11"
            disabled={busy}
            onClick={openCreate}
          >
            <Plus className="size-3.5" />
            {t(TOP_TARIFFS_TEXTS.create)}
          </Button>
        </div>
      </div>

      {error && !modalOpen ? (
        <p className="m-0 rounded-[8px] border border-red-200 bg-red-50 px-3 py-2 text-[12px] text-red-600">
          {error}
        </p>
      ) : null}

      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <TopTariffsTable
          rows={rows}
          loading={loading}
          busy={busy}
          onEdit={openEdit}
          onDelete={setPendingDelete}
        />
      </section>

      <TariffFormDialog
        open={modalOpen}
        editing={Boolean(editing)}
        form={form}
        error={error}
        busy={busy}
        planOptions={availablePlans(rows, editing?.plan)}
        onClose={closeModal}
        onFormChange={setForm}
        onSave={() => {
          void onSave();
        }}
      />

      <ConfirmDialog
        open={Boolean(pendingDelete)}
        title={t(TOP_TARIFFS_TEXTS.confirmDeleteTitle)}
        message={t(TOP_TARIFFS_TEXTS.confirmDelete)}
        confirmLabel={t(TOP_TARIFFS_TEXTS.delete)}
        busy={deleting}
        onCancel={() => setPendingDelete(null)}
        onConfirm={() => {
          void confirmDelete();
        }}
      />

      <ConfirmDialog
        open={pendingReset}
        title={t(TOP_TARIFFS_TEXTS.confirmResetTitle)}
        message={t(TOP_TARIFFS_TEXTS.confirmReset)}
        confirmLabel={t(TOP_TARIFFS_TEXTS.resetAll)}
        busy={resetting}
        onCancel={() => setPendingReset(false)}
        onConfirm={() => {
          void confirmReset();
        }}
      />
    </div>
  );
}
