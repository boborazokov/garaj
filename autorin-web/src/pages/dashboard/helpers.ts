import type { AdminDailyReportRow } from "@/types";
import { DASHBOARD_TEXTS } from "./constants";

export function firstName(fullName: string) {
  return fullName.trim().split(/\s+/)[0] || fullName;
}

export function greetingKey(hour: number): "morning" | "afternoon" | "evening" {
  if (hour < 12) return "morning";
  if (hour < 18) return "afternoon";
  return "evening";
}

export function formatCompact(value: number, language: string) {
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  return (Number.isFinite(value) ? value : 0).toLocaleString(locale);
}

/** Snapshot cards use a clinic-like padded look for small counts. */
export function formatSnapshotValue(value: number, language: string) {
  const safe = Number.isFinite(value) ? Math.max(0, Math.floor(value)) : 0;
  if (safe < 100) return String(safe).padStart(2, "0");
  return formatCompact(safe, language);
}

export function formatChartDate(iso: string) {
  const [, month, day] = iso.split("-");
  return `${Number(day)}/${Number(month)}`;
}

export function periodTrend(rows: AdminDailyReportRow[], pick: (row: AdminDailyReportRow) => number) {
  if (rows.length < 4) return null;
  const mid = Math.floor(rows.length / 2);
  const prev = rows.slice(0, mid).reduce((sum, row) => sum + pick(row), 0);
  const next = rows.slice(mid).reduce((sum, row) => sum + pick(row), 0);
  if (prev === 0) {
    if (next === 0) return { percent: 0, direction: "flat" as const };
    return { percent: 100, direction: "up" as const };
  }
  const percent = Math.round(((next - prev) / prev) * 100);
  if (percent === 0) return { percent: 0, direction: "flat" as const };
  return {
    percent: Math.abs(percent),
    direction: percent > 0 ? ("up" as const) : ("down" as const),
  };
}

export function peakDate(rows: AdminDailyReportRow[], pick: (row: AdminDailyReportRow) => number) {
  let bestDate = rows[0]?.date ?? "";
  let bestValue = -1;
  for (const row of rows) {
    const value = pick(row);
    if (value >= bestValue) {
      bestValue = value;
      bestDate = row.date;
    }
  }
  return bestDate;
}

export function periodLabel(days: number, language: "uz" | "ru" | "en") {
  return DASHBOARD_TEXTS.periodLabel[language].replace("{days}", String(days));
}
