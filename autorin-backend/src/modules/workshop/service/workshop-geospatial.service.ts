import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model, Types } from 'mongoose';
import * as crypto from 'crypto';

import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Part } from 'src/modules/part/schema';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { WorkshopCategory } from 'src/modules/workshop-category/schema/workshop-category.schema';
import { RedisCacheService } from 'src/services/redis-cache/redis-cache.service';

import {
  MapBoundsInput,
  NearbyLatLngArgs,
  WorkshopFiltersInput,
  WorkshopMapDiscoveryArgs,
} from '../dto/inputs/workshop-map-discovery.input';
import { Workshop } from '../schema/workshop.schema';
import { MapSearchResult } from '../types/map-search-result.type';
import {
  distanceToGeoJsonPoint,
  geoFieldGeoFilter,
  geoWithinCenterSphere,
  isValidGeoJsonPoint,
  mapLocationGeoFilter,
} from 'src/shared/geo';
import { normalizeWorkshops } from '../utils/normalize-workshop';
import { computeIsOpenNow } from './workshop-discovery.service';

const populate = [
  { path: 'owner', select: 'name phone' },
  {
    path: 'categoryIds',
    model: COLLECTIONS.WORKSHOP_CATEGORIES,
    select: 'names slug icon color popular',
  },
];

@Injectable()
export class WorkshopGeospatialService {
  private readonly logger = new Logger(WorkshopGeospatialService.name);
  static readonly CACHE_TTL_SEC = 10 * 60;

  constructor(
    @InjectModel(COLLECTIONS.WORKSHOPS)
    private readonly workshopModel: Model<Workshop>,
    @InjectModel(COLLECTIONS.WORKSHOP_CATEGORIES)
    private readonly categoryModel: Model<WorkshopCategory>,
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.SERVICES)
    private readonly serviceModel: Model<AutoService>,
    private readonly redis: RedisCacheService,
  ) {}

  private polygonFromBounds(bounds: MapBoundsInput) {
    const minLng = Math.min(bounds.southWestLng, bounds.northEastLng);
    const maxLng = Math.max(bounds.southWestLng, bounds.northEastLng);
    const minLat = Math.min(bounds.southWestLat, bounds.northEastLat);
    const maxLat = Math.max(bounds.southWestLat, bounds.northEastLat);
    return {
      type: 'Polygon' as const,
      coordinates: [
        [
          [minLng, minLat],
          [maxLng, minLat],
          [maxLng, maxLat],
          [minLng, maxLat],
          [minLng, minLat],
        ],
      ],
    };
  }

  private async buildFilter(filters?: WorkshopFiltersInput) {
    const q: FilterQuery<Workshop> = {
      status: ItemStatusEnum.ACTIVE,
    };

    if (!filters) return q;

    if (filters.verified) q.verified = true;
    if (filters.premium) q.premium = true;
    if (filters.hasPickupService) q.hasPickupService = true;
    if (filters.open24Hours) q.open24Hours = true;
    if (filters.emergencyOnly) q.isEmergency = true;
    if (filters.city?.trim()) {
      q.city = new RegExp(filters.city.trim(), 'i');
    }

    let minR = filters.minRating;
    if (filters.topRated) {
      minR = Math.max(minR ?? 0, 4.5);
    }
    if (minR != null && minR > 0) {
      q.rating = { $gte: minR };
    }

    if (filters.brands?.length) {
      q.supportedCarBrands = { $in: filters.brands };
    }

    if (filters.services?.length) {
      const ids = await this.categoryModel.find({ slug: { $in: filters.services } }).distinct('_id');
      if (ids.length) {
        q.categoryIds = { $in: ids };
      }
    }

    return q;
  }

  private cacheHash(args: WorkshopMapDiscoveryArgs, filterFingerprint: string) {
    const payload = JSON.stringify({
      bounds: args.bounds ?? null,
      lat: Math.round(args.latitude * 5000),
      lng: Math.round(args.longitude * 5000),
      r: Math.round((args.radiusKm ?? 25) * 100),
      filters: filterFingerprint,
      limit: args.limit ?? 120,
    });
    return crypto.createHash('sha256').update(payload).digest('hex').slice(0, 48);
  }

  async workshopsMapDiscovery(args: WorkshopMapDiscoveryArgs): Promise<Workshop[]> {
    const lat = args.latitude;
    const lng = args.longitude;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      this.logger.warn('workshopsMapDiscovery: invalid latitude/longitude');
      return [];
    }

    const limit = Math.min(args.limit ?? 120, 200);
    const baseFilter = await this.buildFilter(args.filters);
    const filterFingerprint = crypto
      .createHash('sha256')
      .update(JSON.stringify(baseFilter))
      .digest('hex')
      .slice(0, 40);

    const cacheId = this.cacheHash(args, filterFingerprint);
    const redisKey = this.redis.keys.mapWorkshops(cacheId);

    try {
      const cachedIds = await this.redis.getJson<string[]>(redisKey);
      if (cachedIds?.length) {
        const objs = await this.workshopModel
          .find({ _id: { $in: cachedIds.map((id) => new Types.ObjectId(id)) } })
          .populate(populate)
          .lean()
          .exec();

        let ordered = objs as Workshop[];
        const idOrder = new Map(cachedIds.map((id, i) => [id, i]));
        ordered.sort(
          (a, b) =>
            (idOrder.get(a._id.toString()) ?? 0) - (idOrder.get(b._id.toString()) ?? 0),
        );

        let norm = normalizeWorkshops(ordered);
        if (args.filters?.openNow) {
          norm = norm.filter((w) =>
            computeIsOpenNow(w.weeklySchedule, w.openFrom, w.openUntil ?? undefined),
          );
        }
        return norm.slice(0, limit) as Workshop[];
      }
    } catch (e) {
      this.logger.warn(`map redis read: ${(e as Error).message}`);
    }

    let rawDocs: Workshop[] = [];

    if (args.bounds) {
      const b = args.bounds;
      if (
        ![b.southWestLat, b.southWestLng, b.northEastLat, b.northEastLng].every(
          Number.isFinite,
        )
      ) {
        this.logger.warn('workshopsMapDiscovery: invalid bounds');
        return [];
      }
      const poly = this.polygonFromBounds(b);
      rawDocs = (await this.workshopModel
        .find({
          ...baseFilter,
          ...mapLocationGeoFilter({ $geoWithin: { $geometry: poly } }),
        })
        .limit(limit + 80)
        .populate(populate)
        .lean()
        .exec()) as Workshop[];
    } else {
      const radiusMeters = (args.radiusKm ?? 25) * 1000;

      rawDocs = (await this.workshopModel
        .find({
          ...baseFilter,
          ...mapLocationGeoFilter(
            geoWithinCenterSphere(lng, lat, radiusMeters),
          ),
        })
        .limit(limit + 80)
        .populate(populate)
        .lean()
        .exec()) as Workshop[];

      rawDocs.sort(
        (a, b) =>
          distanceToGeoJsonPoint(lng, lat, a.mapLocation) -
          distanceToGeoJsonPoint(lng, lat, b.mapLocation),
      );
    }

    rawDocs = rawDocs.filter((d) => isValidGeoJsonPoint(d.mapLocation));

    let list = normalizeWorkshops(rawDocs);
    if (args.filters?.openNow) {
      list = list.filter((w) =>
        computeIsOpenNow(w.weeklySchedule, w.openFrom, w.openUntil ?? undefined),
      );
    }
    list = list.slice(0, limit);

    try {
      await this.redis.setJson(
        redisKey,
        list.map((w) => w._id.toString()),
        WorkshopGeospatialService.CACHE_TTL_SEC,
      );
    } catch (e) {
      this.logger.warn(`map redis write: ${(e as Error).message}`);
    }

    return list as Workshop[];
  }

  async nearbyMapParts(args: NearbyLatLngArgs) {
    const lat = args.lat;
    const lng = args.lng;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return [];

    const radiusMeters = (args.radius ?? 15) * 1000;
    const lim = args.limit ?? 40;

    try {
      let docs = await this.partModel
        .find({
          status: ItemStatusEnum.ACTIVE,
          ...geoFieldGeoFilter('geo', geoWithinCenterSphere(lng, lat, radiusMeters)),
        })
        .limit(lim + 40)
        .populate({ path: 'seller', select: 'name phone' })
        .lean()
        .exec();

      docs = docs.filter((d) => isValidGeoJsonPoint(d.geo));
      docs.sort(
        (a, b) =>
          distanceToGeoJsonPoint(lng, lat, a.geo) -
          distanceToGeoJsonPoint(lng, lat, b.geo),
      );
      return docs.slice(0, lim);
    } catch {
      return [];
    }
  }

  async searchMapEntities(query: string, limitEntities = 20): Promise<MapSearchResult> {
    const q = query.trim();
    if (!q) {
      return { workshops: [], services: [], parts: [] };
    }

    const re = new RegExp(q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');

    const workshopFind = {
      status: ItemStatusEnum.ACTIVE,
      $or: [{ name: re }, { description: re }, { city: re }, { address: re }],
    };

    const serviceFind: FilterQuery<AutoService> = {
      status: ItemStatusEnum.ACTIVE,
      $or: [{ title: re }, { description: re }, { address: re }],
    };

    const partFind: FilterQuery<Part> = {
      status: ItemStatusEnum.ACTIVE,
      $or: [{ name: re }, { description: re }],
    };

    const [workshops, services, parts] = await Promise.all([
      this.workshopModel.find(workshopFind).limit(limitEntities).populate(populate).lean().exec(),
      this.serviceModel
        .find(serviceFind)
        .limit(limitEntities)
        .populate([
          { path: 'owner', select: 'name phone' },
          { path: 'category', select: 'name slug' },
        ])
        .lean()
        .exec(),
      this.partModel.find(partFind).limit(limitEntities).lean().exec(),
    ]);

    return {
      workshops: normalizeWorkshops(workshops as Workshop[]),
      services: services as AutoService[],
      parts: parts as Part[],
    };
  }

  mapMarkerTapped(entityType: string, entityId: string) {
    this.logger.verbose(`map.analytics.tap entityType=${entityType} id=${entityId}`);
  }
}
