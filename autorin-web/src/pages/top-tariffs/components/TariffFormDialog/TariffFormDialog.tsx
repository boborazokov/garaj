import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import type { PromotionPlan } from "@/types";
import {
  DEFAULT_AMOUNTS,
  DEFAULT_DAYS,
  TOP_PLAN_LABELS,
  TOP_TARIFFS_TEXTS,
} from "../../constants";
import { finalAmount, formatUzs } from "../../helpers";
import type { TariffFormDialogProps } from "../../types";

export function TariffFormDialog({
  open,
  editing,
  form,
  error,
  busy,
  planOptions,
  onClose,
  onFormChange,
  onSave,
}: TariffFormDialogProps) {
  const { t } = useLanguage();
  const computed = finalAmount(form);

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onClose();
      }}
    >
      <DialogContent showCloseButton={!busy} className="sm:max-w-[440px]">
        <DialogHeader>
          <DialogTitle>
            {editing
              ? t(TOP_TARIFFS_TEXTS.editTitle)
              : t(TOP_TARIFFS_TEXTS.createTitle)}
          </DialogTitle>
        </DialogHeader>

        <div className="flex flex-col gap-3">
          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(TOP_TARIFFS_TEXTS.plan)}</span>
            <select
              className="h-11 rounded-[8px] border border-[#e2e8f0] bg-white px-3 py-1.5 text-[13px] outline-none focus:border-[#226DF7]"
              disabled={busy || editing}
              value={form.plan}
              onChange={(event) => {
                const plan = event.target.value as PromotionPlan;
                onFormChange({
                  plan,
                  baseAmount: DEFAULT_AMOUNTS[plan],
                  days: DEFAULT_DAYS[plan],
                  discountPercent: 0,
                });
              }}
            >
              {planOptions.map((plan) => (
                <option key={plan} value={plan}>
                  {t(TOP_PLAN_LABELS[plan])}
                </option>
              ))}
            </select>
          </label>

          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(TOP_TARIFFS_TEXTS.days)}</span>
            <Input
              type="text"
              inputMode="numeric"
              disabled={busy}
              value={form.days}
              onChange={(event) => {
                const digits = event.target.value.replace(/[^\d]/g, "");
                onFormChange({
                  ...form,
                  days: digits === "" ? 0 : Number(digits),
                });
              }}
            />
            <span className="text-[12px] text-muted-foreground">
              {t(TOP_TARIFFS_TEXTS.daysHint)}
            </span>
          </label>

          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(TOP_TARIFFS_TEXTS.basePrice)}</span>
            <Input
              type="text"
              inputMode="numeric"
              disabled={busy}
              value={form.baseAmount}
              onChange={(event) => {
                const digits = event.target.value.replace(/[^\d]/g, "");
                onFormChange({
                  ...form,
                  baseAmount: digits === "" ? 0 : Number(digits),
                });
              }}
            />
          </label>

          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(TOP_TARIFFS_TEXTS.discount)}</span>
            <Input
              type="text"
              inputMode="numeric"
              disabled={busy}
              value={form.discountPercent}
              onChange={(event) => {
                const digits = event.target.value.replace(/[^\d]/g, "");
                const next = digits === "" ? 0 : Number(digits);
                onFormChange({
                  ...form,
                  discountPercent: Math.min(100, next),
                });
              }}
            />
          </label>

          <div className="rounded-[8px] border border-[#e2e8f0] bg-slate-50 px-3 py-2.5 text-[13px]">
            <span className="text-muted-foreground">
              {t(TOP_TARIFFS_TEXTS.finalPrice)}:{" "}
            </span>
            <span className="font-medium text-foreground">
              {formatUzs(computed)}
            </span>
          </div>

          {error ? (
            <p className="m-0 text-[12px] text-red-600">{error}</p>
          ) : null}
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
            {t(TOP_TARIFFS_TEXTS.cancel)}
          </Button>
          <Button type="button" disabled={busy} onClick={onSave}>
            {busy ? t(TOP_TARIFFS_TEXTS.saving) : t(TOP_TARIFFS_TEXTS.save)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
