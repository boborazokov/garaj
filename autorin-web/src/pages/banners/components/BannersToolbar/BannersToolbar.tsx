import { Search, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import type { AdvertisementStatus, CategoryType } from "@/types";
import {
  BANNERS_TEXTS,
  PLACEMENT_LABELS,
  PLACEMENT_TYPES,
  STATUS_LABELS,
  STATUS_OPTIONS,
} from "../../constants";
import type { BannersToolbarProps } from "../../types";
import { FilterSelect } from "../FilterSelect";

export function BannersToolbar({
  search,
  placement,
  status,
  canClear,
  onSearchChange,
  onPlacementChange,
  onStatusChange,
  onClear,
}: BannersToolbarProps) {
  const { t } = useLanguage();

  return (
    <div className="flex items-center gap-2 px-3 py-3">
      <div className="relative min-w-[160px] max-w-[240px] flex-[1.2]">
        <Search className="pointer-events-none absolute top-1/2 left-2.5 size-[15px] -translate-y-1/2 text-muted-foreground" />
        <Input
          value={search}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder={t(BANNERS_TEXTS.searchPlaceholder)}
          aria-label={t(BANNERS_TEXTS.searchPlaceholder)}
          className="h-9 pl-[34px]"
        />
      </div>

      <FilterSelect
        value={placement}
        ariaLabel={t(BANNERS_TEXTS.placementFilter)}
        className="w-[160px] flex-none"
        onChange={(value) => onPlacementChange(value as CategoryType)}
        options={PLACEMENT_TYPES.map((item) => ({
          value: item,
          label: t(PLACEMENT_LABELS[item]),
        }))}
      />

      <FilterSelect
        value={status}
        ariaLabel={t(BANNERS_TEXTS.statusFilter)}
        className="w-[150px] flex-none"
        onChange={(value) => onStatusChange(value as "" | AdvertisementStatus)}
        options={STATUS_OPTIONS.map((item) => ({
          value: item,
          label: item ? t(STATUS_LABELS[item]) : t(BANNERS_TEXTS.allStatuses),
        }))}
      />

      {canClear ? (
        <Button
          type="button"
          variant="ghost"
          className="h-9 shrink-0 px-2.5 text-[13px] text-muted-foreground"
          onClick={onClear}
        >
          <X className="size-3.5" />
          {t(BANNERS_TEXTS.clearFilters)}
        </Button>
      ) : null}
    </div>
  );
}
