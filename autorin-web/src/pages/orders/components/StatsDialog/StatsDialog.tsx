import { Eye, Phone, Share2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useLanguage } from "@/lib/i18n";
import { ORDERS_TEXTS } from "../../constants";
import { formatCount } from "../../helpers";
import type { StatsDialogProps } from "../../types";

export function StatsDialog({ order, open, onClose }: StatsDialogProps) {
  const { t, language } = useLanguage();

  const items = [
    {
      key: "views",
      label: t(ORDERS_TEXTS.views),
      value: order?.viewsCount ?? 0,
      icon: Eye,
    },
    {
      key: "phone",
      label: t(ORDERS_TEXTS.phoneClicks),
      value: order?.phoneClickCount ?? 0,
      icon: Phone,
    },
    {
      key: "shares",
      label: t(ORDERS_TEXTS.shares),
      value: order?.shareCount ?? 0,
      icon: Share2,
    },
  ] as const;

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onClose();
      }}
    >
      <DialogContent className="sm:max-w-[360px]">
        <DialogHeader>
          <DialogTitle>{t(ORDERS_TEXTS.statsTitle)}</DialogTitle>
          {order?.title ? (
            <p className="m-0 truncate text-[13px] text-muted-foreground">{order.title}</p>
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
                  {formatCount(item.value, language)}
                </span>
              </div>
            );
          })}
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            {t(ORDERS_TEXTS.close)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
