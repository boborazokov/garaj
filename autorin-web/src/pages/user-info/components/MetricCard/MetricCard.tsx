import type { LucideIcon } from "lucide-react";
import { USER_INFO_COLORS } from "../../constants";

export interface MetricCardProps {
  icon: LucideIcon;
  label: string;
  value: string;
}

export function MetricCard({ icon: Icon, label, value }: MetricCardProps) {
  return (
    <div
      className="flex min-h-[96px] flex-col rounded-[10px] border bg-white p-3.5"
      style={{ borderColor: USER_INFO_COLORS.border }}
    >
      <div className="flex min-w-0 items-center gap-2.5">
        <span
          className="flex size-8 shrink-0 items-center justify-center rounded-full"
          style={{ background: "#f1f5f9", color: USER_INFO_COLORS.textSecondary }}
        >
          <Icon className="size-4" strokeWidth={1.75} />
        </span>
        <span
          className="truncate text-[13px] font-medium"
          style={{ color: USER_INFO_COLORS.muted }}
          title={label}
        >
          {label}
        </span>
      </div>

      <p
        className="truncate text-[17px] font-semibold leading-none tracking-tight"
        style={{ color: USER_INFO_COLORS.text, marginTop: 14 }}
        title={value}
      >
        {value}
      </p>
    </div>
  );
}
