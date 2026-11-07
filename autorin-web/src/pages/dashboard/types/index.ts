import type { LucideIcon } from "lucide-react";
import type { LocalizedText } from "@/lib/i18n";

export type ChartMetric = "visits" | "partsPublished" | "ordersPublished";

export interface MetricCardData {
  label: LocalizedText;
  value: number | undefined;
  icon: LucideIcon;
  trend?: { percent: number; direction: "up" | "down" | "flat" } | null;
}
