import { readFileSync } from 'fs';
import { join } from 'path';

export type VehicleBrandSeed = {
  key: string;
  en: string;
  ru: string;
  uz: string;
  models: string[];
};

export function loadVehicleCatalogSeed(): VehicleBrandSeed[] {
  const candidates = [
    join(__dirname, '..', 'data', 'vehicle-catalog.seed.json'),
    join(process.cwd(), 'src', 'modules', 'category', 'data', 'vehicle-catalog.seed.json'),
    join(process.cwd(), 'dist', 'modules', 'category', 'data', 'vehicle-catalog.seed.json'),
  ];
  for (const path of candidates) {
    try {
      return JSON.parse(readFileSync(path, 'utf8')) as VehicleBrandSeed[];
    } catch {
      /* try next */
    }
  }
  throw new Error('vehicle-catalog.seed.json not found');
}

export function slugModelKey(brandKey: string, modelName: string): string {
  const slug = modelName
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return `${brandKey}-${slug || 'model'}`;
}

export function exactNameRegex(value: string): RegExp {
  const escaped = value.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`^${escaped}$`, 'i');
}
