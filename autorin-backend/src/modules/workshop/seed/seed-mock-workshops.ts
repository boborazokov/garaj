import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { Types } from 'mongoose';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { toGeoJsonPoint } from 'src/shared/geo';

export type MockWorkshopSeedRow = {
  key: string;
  name: string;
  description: string;
  city: string;
  address: string;
  phone: string;
  latitude: number;
  longitude: number;
  rating: number;
  reviewCount: number;
  viewCount: number;
  phoneClickCount?: number;
  bookingCount?: number;
  verified: boolean;
  isPromoted: boolean;
  promotionPlan?: keyof typeof ServicePromotionPlanEnum | null;
  status: keyof typeof ItemStatusEnum;
};

function resolveSeedPath(): string {
  const candidates = [
    join(__dirname, '..', 'data', 'mock-workshops.seed.json'),
    join(process.cwd(), 'src', 'modules', 'workshop', 'data', 'mock-workshops.seed.json'),
    join(process.cwd(), 'dist', 'modules', 'workshop', 'data', 'mock-workshops.seed.json'),
  ];
  for (const path of candidates) {
    if (existsSync(path)) return path;
  }
  throw new Error('mock-workshops.seed.json not found');
}

export function loadMockWorkshopsSeed(): MockWorkshopSeedRow[] {
  const raw = readFileSync(resolveSeedPath(), 'utf8');
  return JSON.parse(raw) as MockWorkshopSeedRow[];
}

export function mockWorkshopToDoc(
  row: MockWorkshopSeedRow,
  ownerId: Types.ObjectId,
  categoryIds: Types.ObjectId[],
) {
  const point = toGeoJsonPoint(row.latitude, row.longitude);
  const plan =
    row.promotionPlan && row.isPromoted
      ? ServicePromotionPlanEnum[row.promotionPlan]
      : row.isPromoted
        ? ServicePromotionPlanEnum.TOP
        : null;
  const promotedUntil = row.isPromoted
    ? new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    : null;

  return {
    name: row.name,
    description: row.description,
    city: row.city,
    address: row.address,
    location: `${row.city}, ${row.address}`,
    phone: row.phone,
    geo: point,
    mapLocation: point,
    serviceRadiusKm: 15,
    coverImage: '',
    logo: '',
    gallery: [],
    images: [],
    categoryIds,
    servicePricing: [],
    weeklySchedule: [],
    openFrom: new Date(),
    openUntil: null,
    telegram: '',
    verified: row.verified,
    premium: plan === ServicePromotionPlanEnum.PREMIUM || plan === ServicePromotionPlanEnum.VIP,
    isPromoted: row.isPromoted,
    promotedUntil,
    promotionPlan: plan,
    promotionPriority: row.isPromoted ? 10 : 0,
    hasPickupService: false,
    open24Hours: false,
    isEmergency: false,
    supportedCarBrands: [],
    rating: row.rating,
    reviewCount: row.reviewCount,
    fastResponse: true,
    responseTimeMinutes: 30,
    bookingCount:
      row.bookingCount ?? Math.max(3, Math.round(row.reviewCount / 3)),
    phoneClickCount:
      row.phoneClickCount ?? Math.max(5, Math.round(row.viewCount * 0.08)),
    viewCount: row.viewCount,
    owner: ownerId,
    status: ItemStatusEnum[row.status] ?? ItemStatusEnum.ACTIVE,
    activeUntil: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
  };
}
