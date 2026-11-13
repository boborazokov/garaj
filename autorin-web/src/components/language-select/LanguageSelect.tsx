import * as SelectPrimitive from "@radix-ui/react-select";
import { Check } from "lucide-react";
import {
  isLanguageCode,
  LANGUAGE_OPTIONS,
  useLanguage,
  type LanguageCode,
} from "@/lib/i18n";
import {
  Select,
  SelectContent,
  SelectTrigger,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";

interface LanguageSelectProps {
  ariaLabel: string;
  /** Compact trigger for app header (flag + code). */
  compact?: boolean;
  className?: string;
  triggerClassName?: string;
}

export function LanguageSelect({
  ariaLabel,
  compact = false,
  className,
  triggerClassName,
}: LanguageSelectProps) {
  const { language, setLanguage } = useLanguage();
  const current =
    LANGUAGE_OPTIONS.find((item) => item.code === language) ??
    LANGUAGE_OPTIONS[0];

  return (
    <div className={cn(className)}>
      <Select
        value={language}
        onValueChange={(value) => {
          if (isLanguageCode(value)) setLanguage(value as LanguageCode);
        }}
      >
        <SelectTrigger
          aria-label={ariaLabel}
          size="sm"
          className={cn(
            "h-9 cursor-pointer gap-2 border-[#dbe3ee] bg-white px-3 text-[13px] font-medium text-slate-600 shadow-none hover:border-[#c5d0de] hover:text-slate-900 focus-visible:border-[#c5d0de] focus-visible:ring-0 [&>svg]:size-3.5 [&>svg]:opacity-70",
            compact && "min-w-[92px]",
            triggerClassName,
          )}
        >
          <span className="inline-flex items-center gap-2">
            <img
              src={current.flag}
              alt=""
              width={18}
              height={18}
              className="size-[18px] rounded-full object-cover"
            />
            <SelectPrimitive.Value>
              {compact ? current.code.toUpperCase() : current.label}
            </SelectPrimitive.Value>
          </span>
        </SelectTrigger>

        <SelectContent
          align="end"
          className="min-w-[180px] rounded-[10px] border-[#e2e8f0] p-1 shadow-[0_8px_24px_rgba(15,23,42,0.08)]"
        >
          {LANGUAGE_OPTIONS.map((item) => (
            <SelectPrimitive.Item
              key={item.code}
              value={item.code}
              className={cn(
                "relative flex w-full cursor-pointer items-center gap-2.5 rounded-[8px] py-2 pr-8 pl-2.5 text-[13px] font-medium text-slate-700 outline-none select-none",
                "data-[highlighted]:bg-[#f1f5f9] data-[highlighted]:text-slate-900",
                "data-[state=checked]:text-slate-900",
              )}
            >
              <img
                src={item.flag}
                alt=""
                width={20}
                height={20}
                className="size-5 shrink-0 rounded-full object-cover"
              />
              <SelectPrimitive.ItemText>{item.label}</SelectPrimitive.ItemText>
              <SelectPrimitive.ItemIndicator className="absolute right-2 flex size-3.5 items-center justify-center">
                <Check className="size-3.5 text-[#226DF7]" strokeWidth={2.25} />
              </SelectPrimitive.ItemIndicator>
            </SelectPrimitive.Item>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
}
