import { Workshop } from '../schema/workshop.schema';
import { computeIsOpenNow } from '../service/workshop-discovery.service';

/** Backfill GraphQL non-null fields for legacy MongoDB documents. */
export function normalizeWorkshop(doc: Workshop | Record<string, unknown>): Workshop {
  const plain =
    typeof (doc as { toObject?: () => Record<string, unknown> }).toObject ===
    'function'
      ? (doc as { toObject: () => Record<string, unknown> }).toObject()
      : { ...(doc as Record<string, unknown>) };

  const gallery = (plain.gallery as string[] | undefined)?.length
    ? (plain.gallery as string[])
    : ((plain.images as string[] | undefined) ?? []);

  const weeklySchedule = (plain.weeklySchedule as Workshop['weeklySchedule']) ?? [];
  const openFrom = plain.openFrom as Date | undefined;
  const openUntil = plain.openUntil as Date | null | undefined;

  return {
    ...(plain as unknown as Workshop),
    description: (plain.description as string) ?? '',
    address: (plain.address as string) ?? '',
    city: (plain.city as string) ?? '',
    location: (plain.location as string) ?? '',
    coverImage: (plain.coverImage as string) ?? '',
    logo: (plain.logo as string) ?? '',
    gallery,
    images: gallery,
    phone: (plain.phone as string) ?? '',
    telegram: (plain.telegram as string) ?? '',
    verified: plain.verified === true,
    premium: plain.premium === true,
    hasPickupService: plain.hasPickupService === true,
    open24Hours: plain.open24Hours === true,
    isEmergency: plain.isEmergency === true,
    supportedCarBrands: Array.isArray(plain.supportedCarBrands)
      ? (plain.supportedCarBrands as string[])
      : [],
    rating: typeof plain.rating === 'number' ? plain.rating : 0,
    reviewCount:
      typeof plain.reviewCount === 'number' ? plain.reviewCount : 0,
    fastResponse: plain.fastResponse === true,
    bookingCount:
      typeof plain.bookingCount === 'number' ? plain.bookingCount : 0,
    viewCount: typeof plain.viewCount === 'number' ? plain.viewCount : 0,
    serviceRadiusKm:
      typeof plain.serviceRadiusKm === 'number' ? plain.serviceRadiusKm : 15,
    servicePricing: (plain.servicePricing as Workshop['servicePricing']) ?? [],
    weeklySchedule,
    categories:
      (plain.categories as Workshop['categories']) ??
      (plain.categoryIds as Workshop['categories']) ??
      [],
    isOpenNow:
      typeof plain.isOpenNow === 'boolean'
        ? plain.isOpenNow
        : computeIsOpenNow(weeklySchedule, openFrom, openUntil),
  };
}

export function normalizeWorkshops(
  docs: Array<Workshop | Record<string, unknown>>,
): Workshop[] {
  return docs.map((d) => normalizeWorkshop(d));
}
