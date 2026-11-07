import type { LanguageCode } from "@/lib/i18n";
import type { WorkshopCategoryRef, WorkshopRow } from "@/types";
import { PERIOD_OPTIONS } from "./constants";

export function idTail(id: string) {
  return id.slice(-6).toUpperCase();
}

export function isWorkshopRecommended(workshop: WorkshopRow) {
  if (!workshop.isPromoted) return false;
  if (!workshop.promotedUntil) return true;
  return new Date(workshop.promotedUntil).getTime() > Date.now();
}

export function formatCount(value: number, language: LanguageCode) {
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  return (Number.isFinite(value) ? value : 0).toLocaleString(locale);
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

export function formatPromoUntil(value: string | null | undefined, language: LanguageCode) {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const day = date.getDate();
  const month = MONTH_NAMES[language]?.[date.getMonth()] ?? MONTH_NAMES.en[date.getMonth()];
  if (language === "en") return `${month} ${day}`;
  return `${day} ${month}`;
}

export function workshopCategoryLabel(
  category: WorkshopCategoryRef | undefined,
  language: LanguageCode,
) {
  if (!category) return "";
  const names = category.names;
  if (names) {
    return (
      names[language]?.trim() ||
      names.uz?.trim() ||
      names.ru?.trim() ||
      names.en?.trim() ||
      category.name?.trim() ||
      category.slug ||
      ""
    );
  }
  return category.name?.trim() || category.slug || "";
}

export function workshopPlace(workshop: WorkshopRow) {
  return [workshop.city, workshop.address || workshop.location].filter(Boolean).join(", ");
}

export function periodBounds(periodId: string) {
  const option = PERIOD_OPTIONS.find((item) => item.id === periodId);
  if (!option || option.days == null) {
    return { createdFrom: undefined as string | undefined, createdTo: undefined as string | undefined };
  }

  const now = new Date();
  const start = new Date(now);
  if (option.days === 0) {
    start.setHours(0, 0, 0, 0);
  } else {
    start.setDate(start.getDate() - option.days);
  }

  return {
    createdFrom: start.toISOString(),
    createdTo: now.toISOString(),
  };
}
