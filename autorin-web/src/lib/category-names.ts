import type { CategoryNames, CategoryRow } from '../types'

export const emptyCategoryNames = (): CategoryNames => ({
  en: '',
  ru: '',
  uz: '',
})

/** Admin table / labels — prefer Russian, fallback to legacy `name`. */
export function categoryLabel(
  row: Pick<CategoryRow, 'name' | 'names'>,
  lang: 'ru' | 'en' | 'uz' = 'ru',
): string {
  const n = row.names
  if (n) {
    const v = n[lang]?.trim()
    if (v) return v
    return n.ru?.trim() || n.en?.trim() || n.uz?.trim() || row.name || '—'
  }
  return row.name?.trim() || '—'
}

export function namesFromRow(
  row: Pick<CategoryRow, 'name' | 'names'>,
): CategoryNames {
  if (row.names) return { ...row.names }
  const s = row.name?.trim() || ''
  return { en: s, ru: s, uz: s }
}
