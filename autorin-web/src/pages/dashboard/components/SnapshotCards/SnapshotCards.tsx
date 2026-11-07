import { ArrowDownRight, ArrowUpRight } from "lucide-react";
import { Skeleton } from "@/components/ui/skeleton";
import { useLanguage } from "@/lib/i18n";
import { DASHBOARD_CARD } from "../../constants";
import { formatSnapshotValue } from "../../helpers";
import type { MetricCardData } from "../../types";

interface SnapshotCardsProps {
  cards: MetricCardData[];
  loading?: boolean;
  columns?: 3 | 4;
}

export function SnapshotCards({ cards, loading, columns = 4 }: SnapshotCardsProps) {
  const { t, language } = useLanguage();
  const gridClass =
    columns === 3
      ? "grid gap-3 sm:grid-cols-2 lg:grid-cols-3"
      : "grid gap-3 sm:grid-cols-2 xl:grid-cols-4";

  return (
    <div className={gridClass}>
      {cards.map((card) => {
        const Icon = card.icon;
        const trend = card.trend;
        const showSkeleton = Boolean(loading && card.value == null);

        return (
          <article key={card.label.en} className={`${DASHBOARD_CARD} px-3.5 py-3`}>
            <div className="mb-2 flex items-start justify-between gap-2">
              <div className="flex size-8 items-center justify-center rounded-[8px] bg-[#f3f5f8] text-slate-700">
                <Icon className="size-4" strokeWidth={1.75} />
              </div>
              {showSkeleton ? (
                <Skeleton className="h-5 w-12 rounded-full" />
              ) : trend && trend.direction !== "flat" ? (
                <span
                  className={`inline-flex items-center gap-0.5 rounded-full px-2 py-0.5 text-[11px] font-semibold tabular-nums ${
                    trend.direction === "down"
                      ? "bg-[#fde8ec] text-[#d1435b]"
                      : "bg-emerald-50 text-emerald-700"
                  }`}
                >
                  {trend.direction === "down" ? (
                    <ArrowDownRight className="size-3" strokeWidth={2.25} />
                  ) : (
                    <ArrowUpRight className="size-3" strokeWidth={2.25} />
                  )}
                  {trend.direction === "down" ? "−" : "+"}
                  {trend.percent}%
                </span>
              ) : null}
            </div>
            <p className="m-0 text-[12px] font-semibold tracking-[0.06em] text-slate-500 uppercase">
              {t(card.label)}
            </p>
            {showSkeleton ? (
              <Skeleton className="mt-2 h-8 w-20" />
            ) : (
              <p className="mt-1.5 mb-0 text-[30px] leading-none font-semibold tracking-tight text-slate-900 tabular-nums">
                {formatSnapshotValue(card.value ?? 0, language)}
              </p>
            )}
          </article>
        );
      })}
    </div>
  );
}
