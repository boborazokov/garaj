export const LANGUAGE_CODES = ["uz", "ru", "en"] as const;

export type LanguageCode = (typeof LANGUAGE_CODES)[number];

export type LocalizedText = Record<LanguageCode, string>;
