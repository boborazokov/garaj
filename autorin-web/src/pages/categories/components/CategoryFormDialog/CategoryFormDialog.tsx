import { Upload } from "lucide-react";
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
import { CATEGORIES_TEXTS, TYPE_LABELS } from "../../constants";
import type { CategoryFormDialogProps } from "../../types";

export function CategoryFormDialog({
  open,
  editing,
  type,
  form,
  iconPreview,
  error,
  busy,
  fileInputRef,
  onClose,
  onFormChange,
  onPickIcon,
  onClearIcon,
  onSave,
}: CategoryFormDialogProps) {
  const { t } = useLanguage();

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !busy) onClose();
      }}
    >
      <DialogContent showCloseButton={!busy} className="sm:max-w-[460px]">
        <DialogHeader>
          <DialogTitle>
            {editing ? t(CATEGORIES_TEXTS.editTitle) : t(CATEGORIES_TEXTS.createTitle)}
            {" · "}
            {t(TYPE_LABELS[type])}
          </DialogTitle>
        </DialogHeader>

        <div className="flex flex-col gap-3">
          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(CATEGORIES_TEXTS.nameRu)} *</span>
            <Input
              value={form.names.ru}
              disabled={busy}
              placeholder={t(CATEGORIES_TEXTS.nameRuPlaceholder)}
              onChange={(event) =>
                onFormChange({
                  ...form,
                  names: { ...form.names, ru: event.target.value },
                })
              }
            />
          </label>

          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(CATEGORIES_TEXTS.nameEn)} *</span>
            <Input
              value={form.names.en}
              disabled={busy}
              placeholder={t(CATEGORIES_TEXTS.nameEnPlaceholder)}
              onChange={(event) =>
                onFormChange({
                  ...form,
                  names: { ...form.names, en: event.target.value },
                })
              }
            />
          </label>

          <label className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(CATEGORIES_TEXTS.nameUz)} *</span>
            <Input
              value={form.names.uz}
              disabled={busy}
              placeholder={t(CATEGORIES_TEXTS.nameUzPlaceholder)}
              onChange={(event) =>
                onFormChange({
                  ...form,
                  names: { ...form.names, uz: event.target.value },
                })
              }
            />
          </label>

          <div className="flex flex-col gap-1.5 text-[13px] text-foreground">
            <span>{t(CATEGORIES_TEXTS.icon)} *</span>
            <div className="flex flex-wrap items-center gap-3">
              <div className="flex size-16 items-center justify-center overflow-hidden rounded-[8px] border border-border bg-slate-50">
                {iconPreview ? (
                  <img src={iconPreview} alt="" className="size-full object-cover" />
                ) : (
                  <Upload className="size-5 text-muted-foreground" />
                )}
              </div>
              <div className="flex flex-col gap-1.5">
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={(event) => onPickIcon(event.target.files?.[0])}
                />
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={busy}
                  className="h-8"
                  onClick={() => fileInputRef.current?.click()}
                >
                  {iconPreview
                    ? t(CATEGORIES_TEXTS.replaceIcon)
                    : t(CATEGORIES_TEXTS.uploadIcon)}
                </Button>
                {iconPreview ? (
                  <button
                    type="button"
                    disabled={busy}
                    className="text-left text-[12px] text-destructive hover:underline disabled:opacity-50"
                    onClick={onClearIcon}
                  >
                    {t(CATEGORIES_TEXTS.removeIcon)}
                  </button>
                ) : null}
              </div>
            </div>
          </div>

          {error ? <p className="m-0 text-[13px] text-destructive">{error}</p> : null}
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
            {t(CATEGORIES_TEXTS.cancel)}
          </Button>
          <Button type="button" disabled={busy} onClick={onSave}>
            {busy ? t(CATEGORIES_TEXTS.saving) : t(CATEGORIES_TEXTS.save)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
