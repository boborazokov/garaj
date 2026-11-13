import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import { USERS_TEXTS } from "../../constants";
import type { RoleConfirmDialogProps } from "../../types";

export function RoleConfirmDialog({
  open,
  title,
  message,
  busy,
  error,
  onCancel,
  onConfirm,
}: RoleConfirmDialogProps) {
  const { t } = useLanguage();
  const [password, setPassword] = useState("");

  useEffect(() => {
    if (!open) setPassword("");
  }, [open]);

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onCancel();
      }}
    >
      <DialogContent showCloseButton={!busy}>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{message}</DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-1.5">
          <label
            htmlFor="role-confirm-password"
            className="text-[12px] font-medium text-muted-foreground"
          >
            {t(USERS_TEXTS.passwordLabel)}
          </label>
          <Input
            id="role-confirm-password"
            type="password"
            autoComplete="current-password"
            value={password}
            disabled={busy}
            placeholder={t(USERS_TEXTS.passwordPlaceholder)}
            onChange={(e) => setPassword(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && password.trim() && !busy) {
                onConfirm(password);
              }
            }}
          />
          {error ? (
            <p className="m-0 text-[12px] text-destructive">{error}</p>
          ) : null}
        </div>
        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onCancel}>
            {t(USERS_TEXTS.cancel)}
          </Button>
          <Button
            type="button"
            disabled={busy || !password.trim()}
            onClick={() => onConfirm(password)}
          >
            {t(USERS_TEXTS.confirm)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
