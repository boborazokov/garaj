import type { LanguageCode } from "@/lib/i18n";
import type { OrderRow } from "@/types";
import { PERIOD_OPTIONS } from "./constants";

export function isOrderRecommended(order: OrderRow) {
  if (!order.isPromoted) return false;
  if (!order.promotedUntil) return true;
  return new Date(order.promotedUntil).getTime() > Date.now();
}

export function formatBudget(
  budget: number | undefined,
  currency: string | undefined,
  language: LanguageCode,
  negotiableLabel: string,
) {
  if (budget == null || budget <= 0) return negotiableLabel;
  const amount = Number.isFinite(budget) ? budget : 0;
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  const code = currency?.trim() || "UZS";
  if (code === "USD") {
    return `$${amount.toLocaleString("en-US", {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    })}`;
  }
  return `${amount.toLocaleString(locale)} ${code}`;
}

const MONTHS: Record<LanguageCode, string[]> = {
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
};

/** Clear admin date: `18-noyabr`, `18 ноября`, `18 November`. Year if not current. */
export function formatDate(value: string | undefined, language: LanguageCode) {
  if (!value) return "—";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "—";

  const day = date.getDate();
  const month = MONTHS[language][date.getMonth()];
  const year = date.getFullYear();
  const showYear = year !== new Date().getFullYear();

  if (language === "uz") {
    return showYear ? `${day}-${month} ${year}` : `${day}-${month}`;
  }
  if (language === "ru") {
    return showYear ? `${day} ${month} ${year}` : `${day} ${month}`;
  }
  return showYear ? `${day} ${month} ${year}` : `${day} ${month}`;
}

export function formatCount(value: number, language: LanguageCode) {
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  return (Number.isFinite(value) ? value : 0).toLocaleString(locale);
}

export function periodBounds(periodId: string) {
  const option = PERIOD_OPTIONS.find((item) => item.id === periodId);
  if (!option || option.days == null) {
    return {
      createdFrom: undefined as string | undefined,
      createdTo: undefined as string | undefined,
    };
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
