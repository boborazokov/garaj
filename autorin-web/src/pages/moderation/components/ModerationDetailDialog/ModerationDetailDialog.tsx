import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useLanguage } from "@/lib/i18n";
import { mediaUrl } from "@/lib/media";
import type { Part } from "@/types";
import { MODERATION_TEXTS } from "../../constants";
import { formatPrice, formatSubmitted } from "../../helpers";

interface ModerationDetailDialogProps {
  open: boolean;
  part: Part | null;
  onClose: () => void;
  onApprove: (part: Part) => void;
  onReject: (part: Part) => void;
}

export function ModerationDetailDialog({
  open,
  part,
  onClose,
  onApprove,
  onReject,
}: ModerationDetailDialogProps) {
  const { t, language } = useLanguage();
  if (!part) return null;

  const images = (part.images ?? []).map((src) => mediaUrl(src)).filter(Boolean) as string[];
  const brand = part.brand?.name?.trim();
  const model = part.carModel?.name?.trim();

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onClose();
      }}
    >
      <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-[640px]">
        <DialogHeader>
          <DialogTitle>{part.name}</DialogTitle>
        </DialogHeader>

        <div className="flex flex-col gap-4 text-[13px]">
          {images.length > 0 ? (
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
              {images.map((src) => (
                <img
                  key={src}
                  src={src}
                  alt={part.name}
                  className="aspect-square w-full rounded-[8px] border border-[#e2e8f0] object-cover"
                />
              ))}
            </div>
          ) : (
            <p className="m-0 text-muted-foreground">{t(MODERATION_TEXTS.noImages)}</p>
          )}

          <dl className="m-0 grid grid-cols-1 gap-2 sm:grid-cols-2">
            <Detail label={t(MODERATION_TEXTS.price)}>
              {formatPrice(part.price, part.currency, language)}
            </Detail>
            <Detail label={t(MODERATION_TEXTS.category)}>
              {part.category?.name?.trim() || "—"}
            </Detail>
            <Detail label={t(MODERATION_TEXTS.brandModel)}>
              {[brand, model].filter(Boolean).join(" · ") || "—"}
            </Detail>
            <Detail label={t(MODERATION_TEXTS.quantity)}>
              {part.quantity ?? "—"}
            </Detail>
            <Detail label={t(MODERATION_TEXTS.seller)}>
              {part.seller?.name?.trim() || "—"}
              {part.seller?.phone ? ` · ${part.seller.phone}` : ""}
            </Detail>
            <Detail label={t(MODERATION_TEXTS.submitted)}>
              {formatSubmitted(part.createdAt, language)}
            </Detail>
          </dl>

          <div>
            <div className="mb-1 font-medium text-muted-foreground">
              {t(MODERATION_TEXTS.description)}
            </div>
            <p className="m-0 whitespace-pre-wrap text-foreground">
              {part.description?.trim() || "—"}
            </p>
          </div>
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            {t(MODERATION_TEXTS.cancel)}
          </Button>
          <Button
            type="button"
            variant="outline"
            className="border-red-200 bg-red-50 text-destructive hover:bg-red-100"
            onClick={() => onReject(part)}
          >
            {t(MODERATION_TEXTS.reject)}
          </Button>
          <Button type="button" onClick={() => onApprove(part)}>
            {t(MODERATION_TEXTS.approve)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function Detail({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="rounded-[8px] border border-[#eef0f3] px-3 py-2">
      <div className="text-[11px] text-muted-foreground">{label}</div>
      <div className="mt-0.5 font-medium text-foreground">{children}</div>
    </div>
  );
}
