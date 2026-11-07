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
import { MODERATION_TEXTS } from "../../constants";
import type { ApproveDialogProps } from "../../types";

export function ApproveDialog({
  open,
  partName,
  busy,
  onCancel,
  onConfirm,
}: ApproveDialogProps) {
  const { t } = useLanguage();

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onCancel();
      }}
    >
      <DialogContent showCloseButton={!busy}>
        <DialogHeader>
          <DialogTitle>{t(MODERATION_TEXTS.confirmApproveTitle)}</DialogTitle>
          <DialogDescription>
            <span className="font-medium text-foreground">{partName}</span>
            {" — "}
            {t(MODERATION_TEXTS.confirmApprove)}
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onCancel}>
            {t(MODERATION_TEXTS.cancel)}
          </Button>
          <Button type="button" disabled={busy} onClick={onConfirm}>
            {t(MODERATION_TEXTS.approve)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
