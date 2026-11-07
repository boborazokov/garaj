import type { LanguageCode, LocalizedText } from "@/lib/i18n";
import type { UserRow } from "@/types";
import {
  ROLE_LABELS,
  type UserRoleOption,
  USERS_TEXTS,
} from "./constants";
import type { RoleFilter, VerifiedFilter } from "./types";

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

export function initialsOf(name?: string | null): string {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return parts.map((part) => part[0]?.toUpperCase() ?? "").join("") || "?";
}

export function roleLabel(
  role: string,
  t: (value: LocalizedText) => string,
): string {
  if (role in ROLE_LABELS) {
    return t(ROLE_LABELS[role as UserRoleOption]);
  }
  return t(USERS_TEXTS.user);
}

/** Compact calendar date, e.g. `12-aprel`. */
export function formatJoined(iso: string | undefined, language: LanguageCode): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";

  const day = date.getDate();
  const monthIndex = date.getMonth();

  if (language === "uz") return `${day}-${MONTHS_UZ[monthIndex]}`;
  if (language === "ru") return `${day} ${MONTHS_RU[monthIndex]}`;
  return `${day} ${MONTHS_EN[monthIndex]}`;
}

export function matchesUserFilters(
  user: UserRow,
  role: RoleFilter,
  verified: VerifiedFilter,
): boolean {
  if (role && user.role !== role) return false;
  if (verified === "verified" && user.verified !== true) return false;
  if (verified === "unverified" && user.verified === true) return false;
  return true;
}
