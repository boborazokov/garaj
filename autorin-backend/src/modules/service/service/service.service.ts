import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { PaginateModel, RootFilterQuery, Types } from 'mongoose';
import * as dayjs from 'dayjs';
import { FileUpload } from 'graphql-upload-ts';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { ownerScope } from 'src/auth/utils/admin-scope';
import { Catalog, COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { MinioService } from 'src/utils/minio';
import {
  distanceToGeoJsonPoint,
  geoFieldGeoFilter,
  geoWithinCenterSphere,
  isValidGeoJsonPoint,
  toGeoJsonPoint,
} from 'src/shared/geo';
import { AutoService } from '../schema/service.schema';
import {
  CreateServiceArgs,
  GetServiceByIdArgs,
  GetServicesArgs,
} from '../dto/args/service.args';
import { PromoteServiceArgs } from '../dto/args/promote-service.args';
import { NearbyArgs } from 'src/shared/geo/nearby.args';
import {
  buildPromotionUpdate,
  servicePromotionWeight,
} from '../utils/promotion';

const populate = [
  { path: 'owner', select: 'name phone role' },
  { path: 'category', select: 'name slug iconUrl' },
];

@Injectable()
export class ServiceListingService {
  constructor(
    @InjectModel(COLLECTIONS.SERVICES)
    private readonly serviceModel: PaginateModel<AutoService>,
    private readonly minioService: MinioService,
  ) {}

  private mapGeo(data: { geoLocation: { latitude: number; longitude: number } }) {
    const { latitude, longitude } = data.geoLocation;
    return toGeoJsonPoint(latitude, longitude);
  }

  async uploadImages(images: Promise<FileUpload>[]) {
    const urls: string[] = [];
    for (const image of images) {
      const file = await this.minioService.prepareFile({
        file: await image,
        compress: false,
      });
      const url = await this.minioService.uploadFile({
        ...file,
        catalog: Catalog.SERVICES_IMAGES,
        compress: true,
      });
      urls.push(url);
    }
    return urls;
  }

  async createService({ data, images }: CreateServiceArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const imageUrls = images?.length ? await this.uploadImages(images) : [];

    const created = await this.serviceModel.create({
      title: data.title,
      description: data.description ?? '',
      category: new Types.ObjectId(data.categoryId),
      geo: this.mapGeo(data),
      address: data.address ?? '',
      images: imageUrls,
      openFrom: data.openFrom,
      openUntil: data.openUntil ?? null,
      phone: data.phone ?? '',
      telegram: data.telegram ?? '',
      features: data.features ?? [],
      isEmergency: data.isEmergency ?? false,
      verified: false,
      rating: 0,
      reviewCount: 0,
      owner: new Types.ObjectId(userId),
      status: ItemStatusEnum.ACTIVE,
      isPromoted: false,
      promotionPriority: 0,
    });

    return this.serviceModel.findById(created._id).populate(populate);
  }

  async getServiceById({ serviceId }: GetServiceByIdArgs) {
    const found = await this.serviceModel
      .findOne({ _id: serviceId, status: ItemStatusEnum.ACTIVE })
      .populate(populate);
    if (!found) throw new BadRequestException('Service not found');
    return found;
  }

  async getServices({ pagination, filter, search }: GetServicesArgs) {
    const query: RootFilterQuery<AutoService> = {
      status: ItemStatusEnum.ACTIVE,
    };

    if (filter?.categoryId) {
      query.category = new Types.ObjectId(filter.categoryId);
    }
    if (filter?.verified === true) query.verified = true;
    if (filter?.isEmergency === true) query.isEmergency = true;
    if (filter?.openNow === true) {
      const now = new Date();
      query.openFrom = { $lte: now } as never;
      query.$or = [
        { openUntil: null },
        { openUntil: { $gte: now } },
      ] as never;
    }
    if (search?.trim()) {
      const re = new RegExp(search.trim(), 'i');
      query.$or = [{ title: re }, { description: re }, { address: re }];
    }

    return this.serviceModel.paginate(query, {
      ...pagination,
      sort: {
        promotionPriority: -1,
        verified: -1,
        rating: -1,
        createdAt: -1,
      },
      populate,
    });
  }

  async nearbyServices(args: NearbyArgs, filter?: { isEmergency?: boolean }) {
    const lat = args.latitude;
    const lng = args.longitude;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return [];

    const radiusMeters = (args.radiusKm ?? 15) * 1000;
    const limit = args.limit ?? 40;

    const match: Record<string, unknown> = {
      status: ItemStatusEnum.ACTIVE,
      ...geoFieldGeoFilter('geo', geoWithinCenterSphere(lng, lat, radiusMeters)),
    };
    if (filter?.isEmergency) match.isEmergency = true;

    let docs = await this.serviceModel
      .find(match)
      .limit(limit + 40)
      .populate(populate)
      .lean()
      .exec();

    docs = docs.filter((d) => isValidGeoJsonPoint(d.geo));
    docs.sort((a, b) => {
      const boost = servicePromotionWeight(b) - servicePromotionWeight(a);
      if (boost !== 0) return boost;
      return (
        distanceToGeoJsonPoint(lng, lat, a.geo) -
        distanceToGeoJsonPoint(lng, lat, b.geo)
      );
    });
    return docs.slice(0, limit);
  }

  async topRatedServices(limit = 20) {
    const docs = await this.serviceModel
      .find({ status: ItemStatusEnum.ACTIVE })
      .limit(Math.max(limit * 3, 60))
      .populate(populate)
      .lean();

    docs.sort((a, b) => {
      const boost = servicePromotionWeight(b) - servicePromotionWeight(a);
      if (boost !== 0) return boost;
      const ratingDiff = (b.rating ?? 0) - (a.rating ?? 0);
      if (ratingDiff !== 0) return ratingDiff;
      return (b.reviewCount ?? 0) - (a.reviewCount ?? 0);
    });
    return docs.slice(0, limit);
  }

  async promoteService({ serviceId, plan }: PromoteServiceArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const promoted = await this.serviceModel.findOneAndUpdate(
      { _id: serviceId, ...ownerScope(context, 'owner', new Types.ObjectId(userId)) },
      { $set: buildPromotionUpdate(plan) },
      { new: true },
    );
    if (!promoted) {
      throw new BadRequestException('Service not found');
    }
    return this.serviceModel.findById(promoted._id).populate(populate);
  }

  isOpenNow(service: AutoService): boolean {
    const now = dayjs();
    const from = dayjs(service.openFrom);
    const until = service.openUntil ? dayjs(service.openUntil) : null;
    if (until) {
      return now.isAfter(from) && now.isBefore(until);
    }
    return now.isAfter(from);
  }
}
