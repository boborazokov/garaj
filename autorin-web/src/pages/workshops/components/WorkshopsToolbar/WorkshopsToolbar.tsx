import { Search, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import type { AdminWorkshopsSort, ItemStatus } from "@/types";
import {
  PERIOD_OPTIONS,
  SHOW_OPTIONS,
  SORT_OPTIONS,
  STATUS_LABELS,
  WORKSHOPS_TEXTS,
} from "../../constants";
import type { ShowFilter, WorkshopsToolbarProps } from "../../types";
import { FilterSelect } from "../FilterSelect";

const STATUS_OPTIONS: { id: "" | ItemStatus }[] = [
  { id: "" },
  { id: "ACTIVE" },
  { id: "PENDING_MODERATION" },
  { id: "ARCHIVED" },
  { id: "REJECTED" },
];

export function WorkshopsToolbar({
  search,
  show,
  sort,
  categoryId,
  status,
  ownerId,
  periodId,
  canClear,
  categories,
  owners,
  onSearchChange,
  onShowChange,
  onSortChange,
  onCategoryChange,
  onStatusChange,
  onOwnerChange,
  onPeriodChange,
  onClear,
}: WorkshopsToolbarProps) {
  const { t } = useLanguage();

  return (
    <div className="flex items-center gap-2 px-3 py-3">
      <div className="relative min-w-[160px] max-w-[240px] flex-[1.2]">
        <Search className="pointer-events-none absolute top-1/2 left-2.5 size-[15px] -translate-y-1/2 text-muted-foreground" />
        <Input
          value={search}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder={t(WORKSHOPS_TEXTS.searchPlaceholder)}
          aria-label={t(WORKSHOPS_TEXTS.searchPlaceholder)}
          className="h-9 pl-[34px]"
        />
      </div>

      <FilterSelect
        value={show}
        emptyValue="all"
        ariaLabel={t(WORKSHOPS_TEXTS.show)}
        onChange={(value) => onShowChange((value || "all") as ShowFilter)}
        options={SHOW_OPTIONS.map((option) => ({
          value: option.id,
          label: t(option.label),
        }))}
      />

      <FilterSelect
        value={sort}
        ariaLabel={t(WORKSHOPS_TEXTS.sort)}
        onChange={(value) => onSortChange((value || "NEWEST") as AdminWorkshopsSort)}
        options={SORT_OPTIONS.map((option) => ({
          value: option.id,
          label: t(option.label),
        }))}
      />

      <FilterSelect
        value={categoryId}
        ariaLabel={t(WORKSHOPS_TEXTS.category)}
        onChange={onCategoryChange}
        options={[
          { value: "", label: t(WORKSHOPS_TEXTS.all) },
          ...categories,
        ]}
      />

      <FilterSelect
        value={status}
        ariaLabel={t(WORKSHOPS_TEXTS.status)}
        onChange={(value) => onStatusChange(value as "" | ItemStatus)}
        options={STATUS_OPTIONS.map((option) => ({
          value: option.id,
          label: option.id ? t(STATUS_LABELS[option.id]) : t(WORKSHOPS_TEXTS.all),
        }))}
      />

      <FilterSelect
        value={ownerId}
        ariaLabel={t(WORKSHOPS_TEXTS.owner)}
        onChange={onOwnerChange}
        options={[
          { value: "", label: t(WORKSHOPS_TEXTS.all) },
          ...owners,
        ]}
      />

      <FilterSelect
        value={periodId}
        ariaLabel={t(WORKSHOPS_TEXTS.period)}
        onChange={onPeriodChange}
        options={PERIOD_OPTIONS.map((option) => ({
          value: option.id,
          label: option.id ? t(option.label) : t(WORKSHOPS_TEXTS.all),
        }))}
      />

      {canClear ? (
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="h-9 shrink-0 border-red-200 bg-red-50 px-2.5 text-[13px] text-red-600 hover:bg-red-100 hover:text-red-700"
          onClick={onClear}
        >
          <X className="size-3.5" />
          {t(WORKSHOPS_TEXTS.clearFilters)}
        </Button>
      ) : null}
    </div>
  );
}
