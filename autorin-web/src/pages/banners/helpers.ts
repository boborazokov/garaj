import type { LanguageCode } from "@/lib/i18n";
import type { AdvertisementStatus } from "@/types";
import type { DurationPreset } from "./constants";
import { DURATION_OPTIONS } from "./constants";
import type { BannerFormState } from "./types";

export function emptyBannerForm(): BannerFormState {
  const startsAt = toDateInputValue(new Date());
  return {
    title: "",
    link: "",
    bannerImageUrl: "",
    startsAt,
    endsAt: addDaysInput(startsAt, 7),
    duration: "7d",
    status: "ACTIVE",
  };
}

export function toDateInputValue(value: Date | string | null | undefined) {
  if (!value) return "";
  const date = typeof value === "string" ? new Date(value) : value;
  if (Number.isNaN(date.getTime())) return "";
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export function addDaysInput(startInput: string, days: number) {
  const base = startInput ? new Date(`${startInput}T12:00:00`) : new Date();
  if (Number.isNaN(base.getTime())) return "";
  base.setDate(base.getDate() + days);
  return toDateInputValue(base);
}

export function applyDuration(
  form: BannerFormState,
  duration: DurationPreset,
): BannerFormState {
  const option = DURATION_OPTIONS.find((item) => item.id === duration);
  if (!option?.days) {
    return { ...form, duration };
  }
  const startsAt = form.startsAt || toDateInputValue(new Date());
  return {
    ...form,
    duration,
    startsAt,
    endsAt: addDaysInput(startsAt, option.days),
  };
}

export function inferDuration(startsAt?: string | null, endsAt?: string | null): DurationPreset {
  if (!startsAt || !endsAt) return "custom";
  const start = new Date(`${startsAt}T12:00:00`);
  const end = new Date(`${endsAt}T12:00:00`);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) return "custom";
  const days = Math.round((end.getTime() - start.getTime()) / 86_400_000);
  const match = DURATION_OPTIONS.find((item) => item.days === days);
  return match?.id ?? "custom";
}

export function dateInputToIso(value: string) {
  if (!value.trim()) return null;
  const date = new Date(`${value.trim()}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime())) return null;
  return date.toISOString();
}

export function endDateInputToIso(value: string) {
  if (!value.trim()) return null;
  const date = new Date(`${value.trim()}T23:59:59.999Z`);
  if (Number.isNaN(date.getTime())) return null;
  return date.toISOString();
}

export function isValidBannerLink(link: string) {
  const v = link.trim();
  if (!v) return false;
  if (v.startsWith("/")) return true;
  try {
    const parsed = new URL(v.includes("://") ? v : `https://${v}`);
    return (
      parsed.protocol === "https:" ||
      parsed.protocol === "http:" ||
      parsed.protocol === "autorin:"
    );
  } catch {
    return false;
  }
}

export function formatCount(value: number, language: LanguageCode) {
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  return (Number.isFinite(value) ? value : 0).toLocaleString(locale);
}

export function formatCtr(value: number, language: LanguageCode) {
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  const n = Number.isFinite(value) ? value : 0;
  return `${n.toLocaleString(locale, { maximumFractionDigits: 2 })}%`;
}

const MONTH_NAMES: Record<LanguageCode, string[]> = {
  en: [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ],
  ru: [
    "января",
    "февраля",
    "марта",
    "апреля",
    "мая",
    "июня",
    "июля",
    "августа",
    "сентября",
    "октября",
    "ноября",
    "декабря",
  ],
  uz: [
    "yanvar",
    "fevral",
    "mart",
    "aprel",
    "may",
    "iyun",
    "iyul",
    "avgust",
    "sentabr",
    "oktabr",
    "noyabr",
    "dekabr",
  ],
};

export function formatBannerDate(value: string | null | undefined, language: LanguageCode) {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const day = date.getDate();
  const month = MONTH_NAMES[language]?.[date.getMonth()] ?? MONTH_NAMES.en[date.getMonth()];
  if (language === "en") return `${month} ${day}`;
  return `${day} ${month}`;
}

export function writableStatus(status: AdvertisementStatus): "ACTIVE" | "PAUSED" {
  return status === "PAUSED" ? "PAUSED" : "ACTIVE";
}
