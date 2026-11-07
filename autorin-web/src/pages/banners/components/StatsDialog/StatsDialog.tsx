import { Eye, MousePointerClick, Percent } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useLanguage } from "@/lib/i18n";
import { BANNERS_TEXTS, STATUS_LABELS } from "../../constants";
import { formatBannerDate, formatCount, formatCtr } from "../../helpers";
import type { StatsDialogProps } from "../../types";

export function StatsDialog({ banner, open, onClose }: StatsDialogProps) {
  const { t, language } = useLanguage();

  const items = [
    {
      key: "impressions",
      label: t(BANNERS_TEXTS.impressions),
      value: formatCount(banner?.impressionCount ?? 0, language),
      icon: Eye,
    },
    {
      key: "clicks",
      label: t(BANNERS_TEXTS.clicks),
      value: formatCount(banner?.clickCount ?? 0, language),
      icon: MousePointerClick,
    },
    {
      key: "ctr",
      label: t(BANNERS_TEXTS.ctr),
      value: formatCtr(banner?.ctr ?? 0, language),
      icon: Percent,
    },
  ] as const;

  const start = formatBannerDate(banner?.startsAt, language);
  const end = formatBannerDate(banner?.endsAt, language);

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onClose();
      }}
    >
      <DialogContent className="sm:max-w-[360px]">
        <DialogHeader>
          <DialogTitle>{t(BANNERS_TEXTS.statsTitle)}</DialogTitle>
          {banner?.title ? (
            <p className="m-0 truncate text-[13px] text-muted-foreground">{banner.title}</p>
          ) : null}
        </DialogHeader>

        <div className="grid gap-2">
          {items.map((item) => {
            const Icon = item.icon;
            return (
              <div
                key={item.key}
                className="flex items-center justify-between gap-3 rounded-[8px] border border-border bg-slate-50/80 px-3 py-2.5"
              >
                <div className="flex min-w-0 items-center gap-2.5">
                  <div className="flex size-8 shrink-0 items-center justify-center rounded-[8px] bg-white text-slate-600 ring-1 ring-border">
                    <Icon className="size-3.5" />
                  </div>
                  <span className="truncate text-[13px] text-slate-600">{item.label}</span>
                </div>
                <span className="text-[15px] font-semibold tabular-nums text-foreground">
                  {item.value}
                </span>
              </div>
            );
          })}
        </div>

        <div className="grid gap-1.5 rounded-[8px] border border-border px-3 py-2.5 text-[13px]">
          <div className="flex justify-between gap-2">
            <span className="text-muted-foreground">{t(BANNERS_TEXTS.startsAt)}</span>
            <span className="font-medium text-foreground">{start || "—"}</span>
          </div>
          <div className="flex justify-between gap-2">
            <span className="text-muted-foreground">{t(BANNERS_TEXTS.endsAt)}</span>
            <span className="font-medium text-foreground">{end || t(BANNERS_TEXTS.noEnd)}</span>
          </div>
          <div className="flex justify-between gap-2">
            <span className="text-muted-foreground">{t(BANNERS_TEXTS.status)}</span>
            <span className="font-medium text-foreground">
              {banner ? t(STATUS_LABELS[banner.status]) : "—"}
            </span>
          </div>
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            {t(BANNERS_TEXTS.close)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
