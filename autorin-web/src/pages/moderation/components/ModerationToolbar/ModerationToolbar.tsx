import { Search, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import { MODERATION_TEXTS } from "../../constants";
import type { ModerationToolbarProps } from "../../types";

export function ModerationToolbar({
  search,
  canClear,
  onSearchChange,
  onClear,
}: ModerationToolbarProps) {
  const { t } = useLanguage();

  return (
    <div className="flex items-center gap-2 px-3 py-3">
      <div className="relative w-full max-w-[340px] shrink-0">
        <Search className="pointer-events-none absolute top-1/2 left-2.5 size-[15px] -translate-y-1/2 text-muted-foreground" />
        <Input
          value={search}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder={t(MODERATION_TEXTS.searchPlaceholder)}
          aria-label={t(MODERATION_TEXTS.searchPlaceholder)}
          className="h-9 pl-[34px]"
        />
      </div>

      {canClear ? (
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="ml-auto h-9 shrink-0 gap-1.5 px-2.5"
          onClick={onClear}
        >
          <X className="size-3.5" />
          {t(MODERATION_TEXTS.clearFilters)}
        </Button>
      ) : null}
    </div>
  );
}
