import { cn } from "@/lib/utils";

export interface SegmentedTabOption<T extends string | number> {
  value: T;
  label: string;
}

interface SegmentedTabsProps<T extends string | number> {
  options: SegmentedTabOption<T>[];
  value: T;
  onChange: (value: T) => void;
  ariaLabel: string;
  size?: "sm" | "md";
  className?: string;
}

export function SegmentedTabs<T extends string | number>({
  options,
  value,
  onChange,
  ariaLabel,
  size = "sm",
  className,
}: SegmentedTabsProps<T>) {
  const compact = size === "sm";

  return (
    <div
      role="tablist"
      aria-label={ariaLabel}
      className={cn(
        "inline-flex items-center gap-0.5 rounded-[9px] border border-[#dbe3ee] bg-[#f1f4f7] p-[3px]",
        compact ? "h-8" : "h-9",
        className,
      )}
    >
      {options.map((option) => {
        const active = option.value === value;
        return (
          <button
            key={String(option.value)}
            type="button"
            role="tab"
            aria-selected={active}
            onClick={() => onChange(option.value)}
            className={cn(
              "cursor-pointer rounded-[7px] font-medium transition-colors",
              compact ? "h-[26px] px-3 text-[9px]" : "h-[30px] px-3.5 text-[9.5px]",
              active
                ? "bg-white text-slate-900 shadow-[0_1px_2px_rgba(15,23,42,0.1)]"
                : "bg-transparent text-slate-500 hover:text-slate-800",
            )}
          >
            {option.label}
          </button>
        );
      })}
    </div>
  );
}
