import type { LanguageCode, LocalizedText } from "@/lib/i18n";
import type { UserRow } from "./types";
import { USER_INFO_TEXTS } from "./constants";

export function initialsOf(name?: string | null): string {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return parts.map((p) => p[0]?.toUpperCase() ?? "").join("") || "?";
}

export function roleLabel(
  role: string,
  t: (value: LocalizedText) => string,
): string {
  if (role === "ADMIN") return t(USER_INFO_TEXTS.admin);
  if (role === "MODERATOR") return t(USER_INFO_TEXTS.moderator);
  return t(USER_INFO_TEXTS.seller);
}

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

export function formatJoined(iso: string | undefined, language: LanguageCode): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";

  const day = date.getDate();
  const monthIndex = date.getMonth();
  const year = date.getFullYear();
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  const time = `${hours}:${minutes}`;

  if (language === "uz") {
    return `${day}-${MONTHS_UZ[monthIndex]} ${year}, ${time}`;
  }
  if (language === "ru") {
    return `${day} ${MONTHS_RU[monthIndex]} ${year}, ${time}`;
  }
  return `${day} ${MONTHS_EN[monthIndex]} ${year}, ${time}`;
}

/** Compact calendar date for tables, e.g. `12-aprel`. */
export function formatProductDate(
  iso: string | undefined,
  language: LanguageCode,
): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";

  const day = date.getDate();
  const monthIndex = date.getMonth();

  if (language === "uz") return `${day}-${MONTHS_UZ[monthIndex]}`;
  if (language === "ru") return `${day} ${MONTHS_RU[monthIndex]}`;
  return `${day} ${MONTHS_EN[monthIndex]}`;
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

export function userFromPeer(
  peer: { _id: string; name?: string | null; phone?: string | null; verified?: boolean | null },
): UserRow {
  return {
    _id: peer._id,
    name: peer.name?.trim() || peer.phone || "—",
    phone: peer.phone ?? "",
    role: "USER",
    verified: peer.verified ?? false,
  };
}
