import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Skeleton } from "@/components/ui/skeleton";
import { useLanguage } from "@/lib/i18n";
import type { AdminDailyReportRow } from "@/types";
import { DASHBOARD_CARD, DASHBOARD_TEXTS } from "../../constants";
import { formatChartDate, formatCompact, peakDate } from "../../helpers";
import type { ChartMetric } from "../../types";
import { SegmentedTabs } from "../SegmentedTabs";

const CHART_SKELETON_BARS = [42, 68, 35, 80, 55, 72, 48, 90, 38, 64, 52, 76];

interface VisitsChartProps {
  rows: AdminDailyReportRow[];
  metric: ChartMetric;
  total: number | undefined;
  onMetricChange: (metric: ChartMetric) => void;
  loading?: boolean;
}

const METRICS: { id: ChartMetric; labelKey: keyof typeof DASHBOARD_TEXTS }[] = [
  { id: "visits", labelKey: "chartMetricVisits" },
  { id: "partsPublished", labelKey: "chartMetricParts" },
  { id: "ordersPublished", labelKey: "chartMetricOrders" },
];

export function VisitsChart({
  rows,
  metric,
  total,
  onMetricChange,
  loading,
}: VisitsChartProps) {
  const { t, language } = useLanguage();
  const pick = (row: AdminDailyReportRow) => row[metric];
  const peak = peakDate(rows, pick);
  const data = rows.map((row) => ({
    ...row,
    label: formatChartDate(row.date),
    value: pick(row),
  }));
  const showChartSkeleton = Boolean(loading && rows.length === 0);
  const totalLabel = DASHBOARD_TEXTS.chartPeriodTotal[language].replace(
    "{value}",
    formatCompact(total ?? 0, language),
  );

  return (
    <section className={`${DASHBOARD_CARD} px-4 pt-3.5 pb-3`}>
      <div className="mb-3 flex flex-wrap items-center justify-between gap-2.5">
        <div className="flex min-w-0 flex-wrap items-baseline gap-x-2.5 gap-y-1">
          <h2 className="m-0 text-[12px] font-semibold tracking-[0.08em] text-slate-500 uppercase">
            {t(DASHBOARD_TEXTS.chartTitle)}
          </h2>
          {showChartSkeleton || total == null ? (
            <Skeleton className="h-3.5 w-28" />
          ) : (
            <p className="m-0 text-[12px] font-medium text-slate-400 tabular-nums">{totalLabel}</p>
          )}
        </div>

        <SegmentedTabs
          ariaLabel={t(DASHBOARD_TEXTS.chartTitle)}
          size="sm"
          value={metric}
          onChange={onMetricChange}
          options={METRICS.map((item) => ({
            value: item.id,
            label: t(DASHBOARD_TEXTS[item.labelKey]),
          }))}
        />
      </div>

      {showChartSkeleton ? (
        <div className="flex h-[280px] w-full min-w-0 items-end gap-2 px-1 pb-2">
          {CHART_SKELETON_BARS.map((height, index) => (
            <Skeleton
              key={`chart-bar-${index}`}
              className="min-w-0 flex-1 rounded-[8px]"
              style={{ height: `${height}%` }}
            />
          ))}
        </div>
      ) : (
        <div className="h-[280px] w-full min-w-0">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data} margin={{ top: 8, right: 8, left: -8, bottom: 4 }}>
              <CartesianGrid vertical={false} stroke="#eef2f7" strokeDasharray="0" />
              <XAxis
                dataKey="label"
                tickLine={false}
                axisLine={false}
                tick={{ fill: "#94a3b8", fontSize: 11 }}
                interval="preserveStartEnd"
                minTickGap={28}
              />
              <YAxis
                tickLine={false}
                axisLine={false}
                tick={{ fill: "#94a3b8", fontSize: 11 }}
                allowDecimals={false}
                width={36}
              />
              <Tooltip
                cursor={{ fill: "rgba(148, 163, 184, 0.1)" }}
                contentStyle={{
                  background: "#ffffff",
                  border: "1px solid #e8edf3",
                  borderRadius: 12,
                  boxShadow: "0 8px 24px rgba(15,23,42,0.08)",
                  fontSize: 12,
                }}
                labelFormatter={(_, payload) =>
                  payload?.[0]?.payload?.date ? String(payload[0].payload.date) : ""
                }
                formatter={(value) => [
                  formatCompact(Number(value ?? 0), language),
                  t(
                    DASHBOARD_TEXTS[
                      metric === "visits"
                        ? "chartMetricVisits"
                        : metric === "partsPublished"
                          ? "chartMetricParts"
                          : "chartMetricOrders"
                    ],
                  ),
                ]}
              />
              <Bar dataKey="value" radius={[8, 8, 4, 4]} maxBarSize={26}>
                {data.map((entry) => (
                  <Cell
                    key={entry.date}
                    fill={entry.date === peak ? "#0f172a" : "#e5eaf0"}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
    </section>
  );
}
