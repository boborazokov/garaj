import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useLanguage } from "@/lib/i18n";
import { cn } from "@/lib/utils";
import { MODERATION_TEXTS } from "../../constants";
import type { RejectDialogProps } from "../../types";

export function RejectDialog({
  open,
  partName,
  note,
  busy,
  onNoteChange,
  onCancel,
  onConfirm,
}: RejectDialogProps) {
  const { t } = useLanguage();
  const canSubmit = note.trim().length > 0;

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onCancel();
      }}
    >
      <DialogContent showCloseButton={!busy}>
        <DialogHeader>
          <DialogTitle>{t(MODERATION_TEXTS.rejectTitle)}</DialogTitle>
          <DialogDescription>
            <span className="font-medium text-foreground">{partName}</span>
            {" — "}
            {t(MODERATION_TEXTS.rejectHint)}
          </DialogDescription>
        </DialogHeader>

        <textarea
          value={note}
          onChange={(event) => onNoteChange(event.target.value)}
          placeholder={t(MODERATION_TEXTS.rejectPlaceholder)}
          rows={4}
          disabled={busy}
          className={cn(
            "w-full resize-none rounded-[8px] border border-input bg-background px-3 py-2 text-[13px] text-foreground shadow-none outline-none transition-colors",
            "placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-2 focus-visible:ring-ring/30",
            "disabled:pointer-events-none disabled:opacity-50",
          )}
        />

        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onCancel}>
            {t(MODERATION_TEXTS.cancel)}
          </Button>
          <Button
            type="button"
            variant="destructive"
            disabled={busy || !canSubmit}
            onClick={onConfirm}
          >
            {t(MODERATION_TEXTS.confirmReject)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
