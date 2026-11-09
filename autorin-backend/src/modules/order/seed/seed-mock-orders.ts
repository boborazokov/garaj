import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { Types } from 'mongoose';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { OrderStatusEnum, OrderUrgencyEnum } from '../enums';

export type MockOrderSeedRow = {
  key: string;
  title: string;
  description: string;
  phone: string;
  location: string;
  region: string;
  brandKey: string;
  modelName: string;
  partCategoryKey: string;
  year?: number | null;
  budget: number;
  currency: string;
  urgency: keyof typeof OrderUrgencyEnum;
  status: keyof typeof OrderStatusEnum;
  isPromoted: boolean;
  daysAgo: number;
};

export type MockOrderCategoryRefs = {
  brandId: Types.ObjectId | null;
  carModelId: Types.ObjectId | null;
  partCategoryId: Types.ObjectId | null;
};

function resolveSeedPath(): string {
  const candidates = [
    join(__dirname, '..', 'data', 'mock-orders.seed.json'),
    join(process.cwd(), 'src', 'modules', 'order', 'data', 'mock-orders.seed.json'),
    join(process.cwd(), 'dist', 'modules', 'order', 'data', 'mock-orders.seed.json'),
  ];
  for (const path of candidates) {
    if (existsSync(path)) return path;
  }
  throw new Error('mock-orders.seed.json not found');
}

export function loadMockOrdersSeed(): MockOrderSeedRow[] {
  const raw = readFileSync(resolveSeedPath(), 'utf8');
  return JSON.parse(raw) as MockOrderSeedRow[];
}

export function mockOrderCreatedAt(daysAgo: number) {
  return new Date(Date.now() - Math.max(0, daysAgo) * 24 * 60 * 60 * 1000);
}

export function mockOrderToDoc(
  row: MockOrderSeedRow,
  authorId: Types.ObjectId,
  refs: MockOrderCategoryRefs,
) {
  const promotedUntil = row.isPromoted
    ? new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    : null;

  return {
    title: row.title,
    description: row.description,
    phone: row.phone,
    location: row.location,
    region: row.region,
    author: authorId,
    brand: refs.brandId,
    carModel: refs.carModelId,
    partCategory: refs.partCategoryId,
    year: row.year ?? null,
    budget: row.budget > 0 ? row.budget : 0,
    currency: row.currency || 'UZS',
    urgency: OrderUrgencyEnum[row.urgency] ?? OrderUrgencyEnum.MEDIUM,
    status: OrderStatusEnum[row.status] ?? OrderStatusEnum.ACTIVE,
    images: [],
    isPromoted: row.isPromoted,
    promotedUntil,
    promotionPlan: row.isPromoted ? ServicePromotionPlanEnum.TOP : null,
    promotionPriority: row.isPromoted ? 10 : 0,
  };
}
