import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import type { CategoryType } from "@/types";
import { CATEGORIES_TEXTS, CATEGORY_TYPES, TYPE_LABELS } from "../../constants";
import type { CategoriesToolbarProps } from "../../types";
import { FilterSelect } from "../FilterSelect";

export function CategoriesToolbar({
  search,
  type,
  onSearchChange,
  onTypeChange,
}: CategoriesToolbarProps) {
  const { t } = useLanguage();

  return (
    <div className="flex items-center justify-between gap-2 px-3 py-3">
      <div className="relative min-w-[160px] max-w-[280px] flex-1">
        <Search className="pointer-events-none absolute top-1/2 left-2.5 size-[15px] -translate-y-1/2 text-muted-foreground" />
        <Input
          value={search}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder={t(CATEGORIES_TEXTS.searchPlaceholder)}
          aria-label={t(CATEGORIES_TEXTS.searchPlaceholder)}
          className="h-9 pl-[34px]"
        />
      </div>

      <FilterSelect
        value={type}
        ariaLabel={t(CATEGORIES_TEXTS.typeFilter)}
        className="w-[180px] flex-none"
        onChange={(value) => onTypeChange(value as CategoryType)}
        options={CATEGORY_TYPES.map((item) => ({
          value: item,
          label: t(TYPE_LABELS[item]),
        }))}
      />
    </div>
  );
}
