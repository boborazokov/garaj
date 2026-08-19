import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  distanceToGeoJsonPoint,
  geoWithinCenterSphere,
  isValidGeoJsonPoint,
  mapLocationGeoFilter,
} from 'src/shared/geo';
import * as dayjs from 'dayjs';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { NearbyArgs } from 'src/shared/geo';
import { Workshop } from '../schema/workshop.schema';
import { WorkshopDaySchedule } from '../schema/workshop-embedded.schema';
import { normalizeWorkshop } from '../utils/normalize-workshop';
import { workshopPromotionWeight } from '../utils/promotion';

const populate = [
  { path: 'owner', select: 'name phone' },
  {
    path: 'categoryIds',
    model: COLLECTIONS.WORKSHOP_CATEGORIES,
    select: 'names slug icon color popular',
  },
];

export function computeIsOpenNow(
  weeklySchedule: WorkshopDaySchedule[] | undefined,
  openFrom?: Date,
  openUntil?: Date | null,
): boolean {
  const now = dayjs();
  const day = now.day();

  if (weeklySchedule?.length) {
    const today = weeklySchedule.find((d) => d.day === day);
    if (today) {
      if (today.closed) return false;
      if (today.openTime && today.closeTime) {
        const [oh, om] = today.openTime.split(':').map(Number);
        const [ch, cm] = today.closeTime.split(':').map(Number);
        const open = now.hour(oh).minute(om).second(0);
        const close = now.hour(ch).minute(cm).second(0);
        return now.isAfter(open) && now.isBefore(close);
      }
    }
  }

  if (!openFrom) return false;
  const from = dayjs(openFrom);
  const until = openUntil ? dayjs(openUntil) : null;
  const t = now.format('HH:mm');
  const fromT = from.format('HH:mm');
  const untilT = until?.format('HH:mm') ?? '23:59';
  return t >= fromT && t <= untilT;
}

@Injectable()
export class WorkshopDiscoveryService {
  constructor(
    @InjectModel(COLLECTIONS.WORKSHOPS)
    private readonly workshopModel: Model<Workshop>,
  ) {}

  private attachComputed(docs: Workshop[]) {
    return docs.map((doc) => normalizeWorkshop(doc));
  }

  async nearbyWorkshops(args: NearbyArgs) {
    const radiusMeters = (args.radiusKm ?? 15) * 1000;
    const limit = args.limit ?? 40;

    let docs = (await this.workshopModel
      .find({
        status: ItemStatusEnum.ACTIVE,
        ...mapLocationGeoFilter(
          geoWithinCenterSphere(args.longitude, args.latitude, radiusMeters),
        ),
      })
      .limit(limit)
      .populate(populate)
      .lean()) as Workshop[];

    docs = docs.filter((d) => isValidGeoJsonPoint(d.mapLocation));
    docs.sort((a, b) => {
      const boost = workshopPromotionWeight(b) - workshopPromotionWeight(a);
      if (boost !== 0) return boost;
      return (
        distanceToGeoJsonPoint(args.longitude, args.latitude, a.mapLocation) -
        distanceToGeoJsonPoint(args.longitude, args.latitude, b.mapLocation)
      );
    });

    if (docs.length < limit) {
      const existing = new Set(docs.map((d) => d._id.toString()));
      const more = await this.workshopModel
        .find({
          status: ItemStatusEnum.ACTIVE,
          mapLocation: { $exists: true, $ne: null },
          _id: { $nin: [...existing].map((id) => new Types.ObjectId(id)) },
        })
        .limit(limit - docs.length)
        .populate(populate)
        .lean();
      docs = [...docs, ...(more as Workshop[])];
    }

    return this.attachComputed(docs);
  }

  async recommendedWorkshops(limit = 12) {
    const docs = await this.workshopModel
      .find({ status: ItemStatusEnum.ACTIVE })
      .limit(Math.max(limit * 3, 36))
      .populate(populate)
      .lean();

    (docs as Workshop[]).sort((a, b) => {
      const boost = workshopPromotionWeight(b) - workshopPromotionWeight(a);
      if (boost !== 0) return boost;
      const verified = Number(b.verified) - Number(a.verified);
      if (verified !== 0) return verified;
      const rating = (b.rating ?? 0) - (a.rating ?? 0);
      if (rating !== 0) return rating;
      return (b.bookingCount ?? 0) - (a.bookingCount ?? 0);
    });

    return this.attachComputed((docs as Workshop[]).slice(0, limit));
  }

  async popularNearby(args: NearbyArgs) {
    const nearby = await this.nearbyWorkshops(args);
    return nearby.sort(
      (a, b) =>
        (b.bookingCount ?? 0) - (a.bookingCount ?? 0) ||
        (b.rating ?? 0) - (a.rating ?? 0),
    );
  }

  async openNowWorkshops(args: NearbyArgs) {
    const nearby = await this.nearbyWorkshops({
      ...args,
      limit: (args.limit ?? 40) * 2,
    });
    return nearby
      .filter((w) => w.isOpenNow)
      .slice(0, args.limit ?? 40);
  }

  async fastResponseNearby(args: NearbyArgs) {
    const nearby = await this.nearbyWorkshops(args);
    return nearby
      .filter((w) => w.fastResponse)
      .slice(0, args.limit ?? 20);
  }

  async searchWorkshops(
    search: string,
    categoryId?: string,
    city?: string,
    limit = 30,
  ) {
    const query: Record<string, unknown> = {
      status: ItemStatusEnum.ACTIVE,
    };
    if (categoryId) {
      query.categoryIds = new Types.ObjectId(categoryId);
    }
    if (city?.trim()) {
      query.city = new RegExp(city.trim(), 'i');
    }
    if (search?.trim()) {
      const re = new RegExp(search.trim(), 'i');
      query.$or = [
        { name: re },
        { description: re },
        { address: re },
        { city: re },
        { location: re },
      ];
    }

    const docs = await this.workshopModel
      .find(query)
      .sort({ verified: -1, rating: -1 })
      .limit(limit)
      .populate(populate)
      .lean();

    return this.attachComputed(docs as Workshop[]);
  }
}
