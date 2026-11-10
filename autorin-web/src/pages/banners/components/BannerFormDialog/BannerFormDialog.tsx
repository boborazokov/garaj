import { ConfigProvider, DatePicker, Select } from "antd";
import enUS from "antd/locale/en_US";
import ruRU from "antd/locale/ru_RU";
import dayjs, { type Dayjs } from "dayjs";
import "dayjs/locale/ru";
import { Loader2, Upload } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { useLanguage, type LanguageCode } from "@/lib/i18n";
import {
  BANNERS_TEXTS,
  DURATION_OPTIONS,
  FALLBACK_AD_PRICES_UZS,
  PLAN_COLUMN_ORDER,
  PLAN_LABELS,
  PLACEMENT_LABELS,
  STATUS_LABELS,
  type AdvertisementPlanId,
  type DurationPreset,
} from "../../constants";
import {
  applyDuration,
  applyPlan,
  formatUzs,
  resolveTariffAmount,
  toDateInputValue,
} from "../../helpers";
import type { BannerFormDialogProps } from "../../types";
import "./banner-form-dialog.css";

function parseDate(value: string): Dayjs | null {
  if (!value) return null;
  const next = dayjs(value, "YYYY-MM-DD", true);
  return next.isValid() ? next : null;
}

function antdLocale(language: LanguageCode) {
  return language === "ru" ? ruRU : enUS;
}

/** Keep Ant popups inside Radix dialog so RemoveScroll doesn't block clicks. */
function popupContainer(trigger: HTMLElement) {
  return (
    (trigger.closest('[data-slot="dialog-content"]') as HTMLElement | null) ??
    document.body
  );
}

export function BannerFormDialog({
  open,
  editing,
  placement,
  form,
  imagePreview,
  error,
  busy,
  fileInputRef,
  planPrices,
  onClose,
  onFormChange,
  onPickImage,
  onClearImage,
  onSave,
}: BannerFormDialogProps) {
  const { t, language } = useLanguage();

  dayjs.locale(language === "ru" ? "ru" : "en");

  const durationOptions = DURATION_OPTIONS.map((option) => {
    const amount =
      option.plan != null
        ? resolveTariffAmount(placement, option.id, planPrices)
        : null;
    return {
      value: option.id,
      label:
        amount != null
          ? `${t(option.label)} · ${formatUzs(amount)}`
          : t(option.label),
    };
  });

  const tariffAmount = form.isFree
    ? 0
    : resolveTariffAmount(placement, form.duration, planPrices);

  const statusOptions = [
    { value: "ACTIVE" as const, label: t(STATUS_LABELS.ACTIVE) },
    { value: "PAUSED" as const, label: t(STATUS_LABELS.PAUSED) },
  ];

  function priceForPlan(plan: AdvertisementPlanId) {
    const fromApi = planPrices?.find(
      (row) => row.placement === placement && row.plan === plan,
    )?.amount;
    if (typeof fromApi === "number") return fromApi;
    return FALLBACK_AD_PRICES_UZS[placement][plan];
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onClose();
      }}
    >
      <DialogContent showCloseButton={!busy} className="sm:max-w-[520px] overflow-visible">
        <DialogHeader>
          <DialogTitle>
            {editing ? t(BANNERS_TEXTS.editTitle) : t(BANNERS_TEXTS.createTitle)}
            {" · "}
            {t(PLACEMENT_LABELS[placement])}
          </DialogTitle>
        </DialogHeader>

        <ConfigProvider
          locale={antdLocale(language)}
          theme={{
            token: {
              colorPrimary: "#226DF7",
              borderRadius: 8,
              controlHeight: 40,
              fontSize: 13,
              zIndexPopupBase: 80,
            },
          }}
        >
          <div className="flex max-h-[70vh] flex-col gap-3 overflow-x-hidden overflow-y-auto pr-1">
            <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
              <span>{t(BANNERS_TEXTS.image)} *</span>
              <div className="overflow-hidden rounded-[8px] border border-dashed border-border bg-slate-50/80">
                {imagePreview ? (
                  <div className="relative">
                    <img
                      src={imagePreview}
                      alt=""
                      className="h-36 w-full object-cover"
                    />
                    <button
                      type="button"
                      disabled={busy}
                      onClick={onClearImage}
                      className="absolute top-2 right-2 rounded-[8px] bg-black/60 px-2 py-1 text-[11px] text-white"
                    >
                      {t(BANNERS_TEXTS.removeImage)}
                    </button>
                  </div>
                ) : (
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() => fileInputRef.current?.click()}
                    className="flex h-36 w-full flex-col items-center justify-center gap-1.5 text-[13px] text-muted-foreground hover:bg-slate-100/80 disabled:opacity-60"
                  >
                    {busy ? (
                      <Loader2 className="size-5 animate-spin" />
                    ) : (
                      <Upload className="size-5" />
                    )}
                    <span>{busy ? t(BANNERS_TEXTS.uploading) : t(BANNERS_TEXTS.pickImage)}</span>
                    <span className="text-[11px]">{t(BANNERS_TEXTS.imageHint)}</span>
                  </button>
                )}
              </div>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={(event) => onPickImage(event.target.files?.[0])}
              />
              {imagePreview ? (
                <button
                  type="button"
                  disabled={busy}
                  onClick={() => fileInputRef.current?.click()}
                  className="self-start text-[12px] text-[#226DF7] hover:underline disabled:opacity-60"
                >
                  {busy ? t(BANNERS_TEXTS.uploading) : t(BANNERS_TEXTS.replaceImage)}
                </button>
              ) : null}
            </div>

            <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
              <span>{t(BANNERS_TEXTS.titleField)} *</span>
              <Input
                value={form.title}
                disabled={busy}
                placeholder={t(BANNERS_TEXTS.titlePlaceholder)}
                onChange={(event) =>
                  onFormChange({ ...form, title: event.target.value })
                }
              />
            </label>

            <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
              <span>{t(BANNERS_TEXTS.link)} *</span>
              <Input
                value={form.link}
                disabled={busy}
                placeholder={t(BANNERS_TEXTS.linkPlaceholder)}
                onChange={(event) =>
                  onFormChange({ ...form, link: event.target.value })
                }
              />
            </label>

            <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
              <span>{t(BANNERS_TEXTS.tariffSelect)}</span>
              <p className="m-0 text-[12px] text-muted-foreground">
                {t(BANNERS_TEXTS.tariffSelectHint)}
              </p>
              <div className="grid grid-cols-2 gap-2">
                {PLAN_COLUMN_ORDER.map((plan) => {
                  const selected = !form.isFree && form.plan === plan;
                  const amount = priceForPlan(plan);
                  return (
                    <button
                      key={plan}
                      type="button"
                      disabled={busy}
                      onClick={() => onFormChange(applyPlan(form, plan))}
                      className={[
                        "rounded-[8px] border px-3 py-2.5 text-left transition-colors",
                        selected
                          ? "border-[#226DF7] bg-[#226DF7]/8"
                          : "border-border bg-white hover:bg-slate-50",
                        busy ? "opacity-60" : "",
                      ].join(" ")}
                    >
                      <div className="text-[12px] font-medium text-foreground">
                        {t(PLAN_LABELS[plan])}
                      </div>
                      <div className="mt-0.5 text-[13px] font-semibold text-foreground">
                        {formatUzs(amount)}
                      </div>
                    </button>
                  );
                })}
              </div>
              <label className="mt-1 flex cursor-pointer items-center gap-2 text-[12px] text-muted-foreground">
                <input
                  type="checkbox"
                  checked={form.isFree}
                  disabled={busy}
                  onChange={(event) =>
                    onFormChange({
                      ...form,
                      isFree: event.target.checked,
                      plan: event.target.checked ? null : form.plan ?? "WEEK",
                    })
                  }
                />
                {t(BANNERS_TEXTS.tariffFree)}
              </label>
            </div>

            <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
              <span>{t(BANNERS_TEXTS.duration)}</span>
              <Select
                value={form.duration}
                disabled={busy || form.isFree}
                options={durationOptions}
                getPopupContainer={popupContainer}
                className="w-full banner-antd-control"
                onChange={(value) => {
                  const duration = value as DurationPreset;
                  const option = DURATION_OPTIONS.find((item) => item.id === duration);
                  onFormChange({
                    ...applyDuration(form, duration),
                    plan: option?.plan ?? null,
                    isFree: false,
                  });
                }}
              />
            </div>

            <div className="grid grid-cols-2 gap-2.5 overflow-visible">
              <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
                <span>{t(BANNERS_TEXTS.startsAt)}</span>
                <DatePicker
                  value={parseDate(form.startsAt)}
                  disabled={busy}
                  allowClear={false}
                  format="D MMMM YYYY"
                  className="w-full banner-antd-control"
                  getPopupContainer={popupContainer}
                  onChange={(value) => {
                    const startsAt = value ? toDateInputValue(value.toDate()) : "";
                    if (form.duration !== "custom") {
                      onFormChange(applyDuration({ ...form, startsAt }, form.duration));
                      return;
                    }
                    onFormChange({ ...form, startsAt, duration: "custom", plan: null });
                  }}
                />
              </div>
              <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
                <span>{t(BANNERS_TEXTS.endsAt)}</span>
                <DatePicker
                  value={parseDate(form.endsAt)}
                  disabled={busy}
                  allowClear
                  format="D MMMM YYYY"
                  minDate={parseDate(form.startsAt) ?? undefined}
                  className="w-full banner-antd-control"
                  getPopupContainer={popupContainer}
                  onChange={(value) =>
                    onFormChange({
                      ...form,
                      endsAt: value ? toDateInputValue(value.toDate()) : "",
                      duration: "custom",
                      plan: null,
                    })
                  }
                />
              </div>
            </div>

            <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
              <span>{t(BANNERS_TEXTS.status)}</span>
              <Select
                value={form.status}
                disabled={busy}
                options={statusOptions}
                getPopupContainer={popupContainer}
                className="w-full banner-antd-control"
                onChange={(value) =>
                  onFormChange({
                    ...form,
                    status: value as "ACTIVE" | "PAUSED",
                  })
                }
              />
            </div>

            <div className="rounded-[8px] border border-border bg-slate-50/80 px-3 py-2.5 text-[13px]">
              <div className="text-[12px] text-muted-foreground">
                {t(BANNERS_TEXTS.tariffPrice)}
              </div>
              <div className="mt-0.5 font-semibold text-foreground">
                {form.isFree
                  ? t(BANNERS_TEXTS.tariffFree)
                  : tariffAmount != null
                    ? formatUzs(tariffAmount)
                    : t(BANNERS_TEXTS.tariffCustomHint)}
              </div>
            </div>

            {error ? <p className="m-0 text-[13px] text-destructive">{error}</p> : null}
          </div>
        </ConfigProvider>

        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
            {t(BANNERS_TEXTS.cancel)}
          </Button>
          <Button type="button" disabled={busy} onClick={onSave}>
            {busy ? t(BANNERS_TEXTS.saving) : t(BANNERS_TEXTS.save)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
