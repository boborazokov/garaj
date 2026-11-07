import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import type { FilterSelectOption } from "../../types";

const EMPTY_VALUE = "__all__";

interface FilterSelectProps {
  value: string;
  emptyValue?: string;
  options: FilterSelectOption[];
  ariaLabel: string;
  className?: string;
  onChange: (value: string) => void;
}

export function FilterSelect({
  value,
  emptyValue = "",
  options,
  ariaLabel,
  className,
  onChange,
}: FilterSelectProps) {
  const isEmpty = !value || value === emptyValue;
  const selectedOption = options.find((option) => option.value === value);

  return (
    <Select
      value={isEmpty ? EMPTY_VALUE : value}
      onValueChange={(next) => onChange(next === EMPTY_VALUE ? emptyValue : next)}
    >
      <SelectTrigger
        aria-label={ariaLabel}
        className={cn("h-9 min-w-0 flex-1 text-[13px]", className)}
      >
        <span className={cn("min-w-0 flex-1 truncate text-left", isEmpty && "text-muted-foreground")}>
          {isEmpty ? ariaLabel : selectedOption?.label ?? ariaLabel}
        </span>
      </SelectTrigger>
      <SelectContent className="min-w-[220px]">
        <SelectGroup>
          <SelectLabel>{ariaLabel}</SelectLabel>
          {options.map((option) => (
            <SelectItem
              key={option.value || EMPTY_VALUE}
              value={option.value === emptyValue || !option.value ? EMPTY_VALUE : option.value}
            >
              {option.label}
            </SelectItem>
          ))}
        </SelectGroup>
      </SelectContent>
    </Select>
  );
}
