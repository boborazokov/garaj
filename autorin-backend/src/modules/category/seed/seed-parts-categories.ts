import { readFileSync } from 'fs';
import { join } from 'path';
import { CategoryTypeEnum } from '../enums';

type PartsSeedRow = {
  key: string;
  icon: string;
  ru: string;
  en: string;
  uz: string;
};

export function loadPartsCategoriesSeed(): PartsSeedRow[] {
  const candidates = [
    join(__dirname, '..', 'data', 'parts-categories.seed.json'),
    join(process.cwd(), 'src', 'modules', 'category', 'data', 'parts-categories.seed.json'),
    join(process.cwd(), 'dist', 'modules', 'category', 'data', 'parts-categories.seed.json'),
  ];
  for (const path of candidates) {
    try {
      return JSON.parse(readFileSync(path, 'utf8')) as PartsSeedRow[];
    } catch {
      /* try next */
    }
  }
  throw new Error('parts-categories.seed.json not found');
}

export function partsSeedToCategoryDocs(rows: PartsSeedRow[]) {
  return rows.map((row) => ({
    key: row.key,
    icon: row.icon,
    iconUrl: '',
    type: CategoryTypeEnum.PART,
    parentId: null,
    names: { ru: row.ru.trim(), en: row.en.trim(), uz: row.uz.trim() },
  }));
}
