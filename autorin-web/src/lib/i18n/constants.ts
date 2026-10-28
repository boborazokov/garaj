import uzFlag from "@/assets/flags/uzbekistan.svg";
import ruFlag from "@/assets/flags/russia.svg";
import enFlag from "@/assets/flags/united-states-of-america.svg";
import type { LanguageCode } from "./types";

export const LANGUAGE_STORAGE_KEY = "autorin-language";
export const DEFAULT_LANGUAGE: LanguageCode = "uz";

export const LANGUAGE_OPTIONS: {
  code: LanguageCode;
  flag: string;
  label: string;
}[] = [
  { code: "uz", flag: uzFlag, label: "O'zbekcha" },
  { code: "ru", flag: ruFlag, label: "Русский" },
  { code: "en", flag: enFlag, label: "English" },
];
