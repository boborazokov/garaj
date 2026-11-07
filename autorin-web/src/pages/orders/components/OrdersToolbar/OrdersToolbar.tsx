import { Search, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import type { AdminOrdersSort, OrderStatus } from "@/types";
import {
  ORDERS_TEXTS,
  PERIOD_OPTIONS,
  SHOW_OPTIONS,
  SORT_OPTIONS,
  STATUS_LABELS,
} from "../../constants";
import type { OrdersToolbarProps, ShowFilter } from "../../types";
import { FilterSelect } from "../FilterSelect";

const STATUS_OPTIONS: { id: "" | OrderStatus }[] = [
  { id: "" },
  { id: "ACTIVE" },
  { id: "CLOSED" },
  { id: "CANCELLED" },
];

export function OrdersToolbar({
  search,
  show,
  sort,
  categoryId,
  status,
  authorId,
  periodId,
  canClear,
  categories,
  authors,
  onSearchChange,
  onShowChange,
  onSortChange,
  onCategoryChange,
  onStatusChange,
  onAuthorChange,
  onPeriodChange,
  onClear,
}: OrdersToolbarProps) {
  const { t } = useLanguage();

  return (
    <div className="flex items-center gap-2 px-3 py-3">
      <div className="relative min-w-[160px] max-w-[240px] flex-[1.2]">
        <Search className="pointer-events-none absolute top-1/2 left-2.5 size-[15px] -translate-y-1/2 text-muted-foreground" />
        <Input
          value={search}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder={t(ORDERS_TEXTS.searchPlaceholder)}
          aria-label={t(ORDERS_TEXTS.searchPlaceholder)}
          className="h-9 pl-[34px]"
        />
      </div>

      <FilterSelect
        value={show}
        emptyValue="all"
        ariaLabel={t(ORDERS_TEXTS.show)}
        onChange={(value) => onShowChange((value || "all") as ShowFilter)}
        options={SHOW_OPTIONS.map((option) => ({
          value: option.id,
          label: t(option.label),
        }))}
      />

      <FilterSelect
        value={sort}
        ariaLabel={t(ORDERS_TEXTS.sort)}
        onChange={(value) => onSortChange((value || "NEWEST") as AdminOrdersSort)}
        options={SORT_OPTIONS.map((option) => ({
          value: option.id,
          label: t(option.label),
        }))}
      />

      <FilterSelect
        value={categoryId}
        ariaLabel={t(ORDERS_TEXTS.category)}
        onChange={onCategoryChange}
        options={[{ value: "", label: t(ORDERS_TEXTS.all) }, ...categories]}
      />

      <FilterSelect
        value={status}
        ariaLabel={t(ORDERS_TEXTS.status)}
        onChange={(value) => onStatusChange(value as "" | OrderStatus)}
        options={STATUS_OPTIONS.map((option) => ({
          value: option.id,
          label: option.id ? t(STATUS_LABELS[option.id]) : t(ORDERS_TEXTS.all),
        }))}
      />

      <FilterSelect
        value={authorId}
        ariaLabel={t(ORDERS_TEXTS.author)}
        onChange={onAuthorChange}
        options={[{ value: "", label: t(ORDERS_TEXTS.all) }, ...authors]}
      />

      <FilterSelect
        value={periodId}
        ariaLabel={t(ORDERS_TEXTS.period)}
        onChange={onPeriodChange}
        options={PERIOD_OPTIONS.map((option) => ({
          value: option.id,
          label: option.id ? t(option.label) : t(ORDERS_TEXTS.all),
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
          {t(ORDERS_TEXTS.clearFilters)}
        </Button>
      ) : null}
    </div>
  );
}
