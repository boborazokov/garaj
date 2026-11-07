import type { LanguageCode } from "@/lib/i18n";

const MONTHS_UZ = [
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
] as const;

const MONTHS_RU = [
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
] as const;

const MONTHS_EN = [
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
] as const;

export function skuFromId(id: string) {
  return id.slice(-6).toUpperCase();
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

/** Compact calendar date, e.g. `12-aprel`. */
export function formatSubmitted(iso: string | undefined, language: LanguageCode): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";

  const day = date.getDate();
  const monthIndex = date.getMonth();

  if (language === "uz") return `${day}-${MONTHS_UZ[monthIndex]}`;
  if (language === "ru") return `${day} ${MONTHS_RU[monthIndex]}`;
  return `${day} ${MONTHS_EN[monthIndex]}`;
}
