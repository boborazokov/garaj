import type { LanguageCode } from "@/lib/i18n";
import type {
  AdvertisementPlanPrice,
  AdvertisementStatus,
  CategoryType,
} from "@/types";
import type { AdvertisementPlanId, DurationPreset } from "./constants";
import { DURATION_OPTIONS, FALLBACK_AD_PRICES_UZS } from "./constants";
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
    plan: "WEEK",
    isFree: false,
    status: "ACTIVE",
  };
}

export function planFromDuration(duration: DurationPreset): AdvertisementPlanId | null {
  return DURATION_OPTIONS.find((item) => item.id === duration)?.plan ?? null;
}

export function durationFromPlan(plan: AdvertisementPlanId): DurationPreset {
  return DURATION_OPTIONS.find((item) => item.plan === plan)?.id ?? "7d";
}

export function applyPlan(
  form: BannerFormState,
  plan: AdvertisementPlanId,
): BannerFormState {
  const duration = durationFromPlan(plan);
  return {
    ...applyDuration(form, duration),
    plan,
    isFree: false,
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

export function formatUzs(amount: number) {
  const n = Number.isFinite(amount) ? Math.round(amount) : 0;
  return `${n.toLocaleString("ru-RU")} UZS`;
}

export function resolveTariffAmount(
  placement: CategoryType,
  duration: DurationPreset,
  prices?: AdvertisementPlanPrice[],
): number | null {
  const option = DURATION_OPTIONS.find((item) => item.id === duration);
  const plan = option?.plan as AdvertisementPlanId | undefined;
  if (!plan) return null;
  const fromApi = prices?.find(
    (row) => row.placement === placement && row.plan === plan,
  )?.amount;
  if (typeof fromApi === "number") return fromApi;
  return FALLBACK_AD_PRICES_UZS[placement][plan];
}
