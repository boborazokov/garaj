import { readFileSync } from 'fs';
import { join } from 'path';

export type WorkshopSeedRow = {
  slug: string;
  icon: string;
  popular: boolean;
  color: string;
  ru: string;
  en: string;
  uz: string;
};

export function loadWorkshopCategoriesSeed(): WorkshopSeedRow[] {
  const candidates = [
    join(__dirname, '..', 'data', 'workshop-categories.seed.json'),
    join(process.cwd(), 'src', 'modules', 'workshop-category', 'data', 'workshop-categories.seed.json'),
    join(process.cwd(), 'dist', 'modules', 'workshop-category', 'data', 'workshop-categories.seed.json'),
  ];
  for (const path of candidates) {
    try {
      return JSON.parse(readFileSync(path, 'utf8')) as WorkshopSeedRow[];
    } catch {
      /* try next */
    }
  }
  throw new Error('workshop-categories.seed.json not found');
}

export function workshopSeedToDocs(rows: WorkshopSeedRow[]) {
  return rows.map((row) => ({
    slug: row.slug,
    icon: row.icon,
    color: row.color,
    popular: row.popular,
    names: { ru: row.ru.trim(), en: row.en.trim(), uz: row.uz.trim() },
  }));
}
