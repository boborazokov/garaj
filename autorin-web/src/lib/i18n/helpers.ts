import { LANGUAGE_CODES, type LanguageCode, type LocalizedText } from "./types";
import { DEFAULT_LANGUAGE, LANGUAGE_STORAGE_KEY } from "./constants";

export function isLanguageCode(value: string): value is LanguageCode {
  return (LANGUAGE_CODES as readonly string[]).includes(value);
}

export function readStoredLanguage(): LanguageCode {
  if (typeof window === "undefined") return DEFAULT_LANGUAGE;
  const stored = window.localStorage.getItem(LANGUAGE_STORAGE_KEY);
  return stored && isLanguageCode(stored) ? stored : DEFAULT_LANGUAGE;
}

export function persistLanguage(language: LanguageCode) {
  window.localStorage.setItem(LANGUAGE_STORAGE_KEY, language);
}

export function pickText(text: LocalizedText, language: LanguageCode) {
  return text[language];
}
