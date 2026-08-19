import { BadRequestException } from '@nestjs/common';
import { CategoryNames } from '../types/category-names.type';

export type CategoryNamesRecord = {
  en: string;
  ru: string;
  uz: string;
};

const FALLBACK = '—';

export function normalizeCategoryNames(raw: unknown): CategoryNamesRecord {
  if (raw && typeof raw === 'object') {
    const o = raw as Record<string, unknown>;
    if ('en' in o || 'ru' in o || 'uz' in o) {
      return {
        en: trimOrFallback(o.en),
        ru: trimOrFallback(o.ru),
        uz: trimOrFallback(o.uz),
      };
    }
  }

  if (typeof raw === 'string' && raw.trim()) {
    const s = raw.trim();
    return { en: s, ru: s, uz: s };
  }

  return { en: FALLBACK, ru: FALLBACK, uz: FALLBACK };
}

export function normalizeCategoryNamesInput(
  raw: CategoryNames | undefined,
): CategoryNamesRecord {
  if (!raw) {
    throw new BadRequestException('Category names (ru, en, uz) are required');
  }
  const names = normalizeCategoryNames(raw);
  if (
    names.en === FALLBACK &&
    names.ru === FALLBACK &&
    names.uz === FALLBACK
  ) {
    throw new BadRequestException('At least one category name is required');
  }
  if (!names.ru.trim() || !names.en.trim() || !names.uz.trim()) {
    throw new BadRequestException('Fill name in Russian, English and Uzbek');
  }
  return names;
}

/** Picks label for active app language (ru | en | uz). */
export function pickCategoryName(
  names: CategoryNamesRecord,
  locale?: string | null,
): string {
  const code = (locale ?? 'ru').toLowerCase().split('-')[0];
  if (code === 'uz') return firstNonEmpty(names.uz, names.ru, names.en);
  if (code === 'en') return firstNonEmpty(names.en, names.ru, names.uz);
  return firstNonEmpty(names.ru, names.en, names.uz);
}

export function resolveCategoryNamesFromDoc(doc: {
  names?: unknown;
  name?: unknown;
}): CategoryNamesRecord {
  if (doc.names) return normalizeCategoryNames(doc.names);
  return normalizeCategoryNames(doc.name);
}

function trimOrFallback(value: unknown): string {
  if (typeof value === 'string' && value.trim()) return value.trim();
  return '';
}

function firstNonEmpty(...values: string[]): string {
  for (const v of values) {
    if (v.trim()) return v.trim();
  }
  return FALLBACK;
}
