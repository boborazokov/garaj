import { useEffect, useMemo, useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
} from "@/components/ui/select";
import { useLanguage } from "@/lib/i18n";
import type { PromotionPlan } from "@/types";
import {
  PRODUCTS_TEXTS,
  PROMOTE_PLAN_LABELS,
  PROMOTE_PLAN_ORDER,
} from "../../constants";
import type { PromotePlanDialogProps } from "../../types";

function formatUzs(amount: number) {
  return `${amount.toLocaleString("uz-UZ")} UZS`;
}

export function PromotePlanDialog({
  open,
  partName,
  prices,
  busy,
  error,
  onCancel,
  onConfirm,
}: PromotePlanDialogProps) {
  const { t } = useLanguage();
  const [plan, setPlan] = useState<PromotionPlan | "">("");

  useEffect(() => {
    if (open) setPlan("");
  }, [open]);

  const options = useMemo(
    () =>
      PROMOTE_PLAN_ORDER.map((id) => {
        const row = prices.find((item) => item.plan === id);
        return {
          plan: id,
          days: row?.days ?? 0,
          amount: row?.amount ?? 0,
        };
      }),
    [prices],
  );

  const selected = options.find((option) => option.plan === plan);

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onCancel();
      }}
    >
      <DialogContent showCloseButton={!busy} className="sm:max-w-[420px]">
        <DialogHeader>
          <DialogTitle>{t(PRODUCTS_TEXTS.promoteTitle)}</DialogTitle>
          <DialogDescription>
            {partName
              ? `${t(PRODUCTS_TEXTS.promoteHint)} — ${partName}`
              : t(PRODUCTS_TEXTS.promoteHint)}
          </DialogDescription>
        </DialogHeader>

        <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
          <span>{t(PRODUCTS_TEXTS.promotePlan)}</span>
          <Select
            value={plan || undefined}
            disabled={busy}
            onValueChange={(value) => setPlan(value as PromotionPlan)}
          >
            <SelectTrigger
              aria-label={t(PRODUCTS_TEXTS.promotePlan)}
              className="h-11 w-full"
            >
              <span className="truncate">
                {selected
                  ? t(PROMOTE_PLAN_LABELS[selected.plan])
                  : t(PRODUCTS_TEXTS.promotePlanHint)}
              </span>
            </SelectTrigger>
            <SelectContent className="min-w-[var(--radix-select-trigger-width)]">
              {options.map((option) => (
                <SelectItem key={option.plan} value={option.plan}>
                  <span className="flex w-full min-w-0 items-center justify-between gap-3">
                    <span className="truncate">
                      {t(PROMOTE_PLAN_LABELS[option.plan])}
                    </span>
                    <span className="shrink-0 text-[12px] text-muted-foreground">
                      {option.days} {t(PRODUCTS_TEXTS.daysShort)}
                      {option.amount > 0 ? ` · ${formatUzs(option.amount)}` : ""}
                    </span>
                  </span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {error ? (
            <p className="m-0 text-[12px] text-red-600">{error}</p>
          ) : null}
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onCancel}>
            {t(PRODUCTS_TEXTS.cancel)}
          </Button>
          <Button
            type="button"
            disabled={busy || !plan}
            onClick={() => {
              if (!plan) return;
              onConfirm(plan);
            }}
          >
            {t(PRODUCTS_TEXTS.promoteConfirm)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
