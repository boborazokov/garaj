import type { LanguageCode } from "@/lib/i18n";
import type { Part } from "@/types";
import { PERIOD_OPTIONS } from "./constants";

export function skuFromId(id: string) {
  return id.slice(-6).toUpperCase();
}

export function isPartRecommended(part: Part) {
  if (!part.isPromoted) return false;
  if (!part.promotedUntil) return true;
  return new Date(part.promotedUntil).getTime() > Date.now();
}

export function formatPrice(price: number, currency: string, language: LanguageCode) {
  const amount = Number.isFinite(price) ? price : 0;
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  if (currency === "USD") {
    return `$${amount.toLocaleString("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  }
  return `${amount.toLocaleString(locale)} ${currency}`;
}

export function formatCount(value: number, language: LanguageCode) {
  const locale = language === "ru" ? "ru-RU" : language === "uz" ? "uz-UZ" : "en-US";
  return (Number.isFinite(value) ? value : 0).toLocaleString(locale);
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
