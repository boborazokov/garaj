import { BadRequestException, Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Catalog, COLLECTIONS } from 'src/constants';
import { Workshop } from '../schema';
import { PaginateModel, RootFilterQuery, Types } from 'mongoose';
import {
  CreateWorkshopArgs,
  GetWorkshopByIdArgs,
  GetWorkshopsArgs,
  UpdateWorkshopByIdArgs,
} from '../dto';
import { FileUpload } from 'graphql-upload-ts';
import { MinioService } from 'src/utils/minio';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { POPULATIONS } from 'src/constants/populations.constants';
import { ViewService } from 'src/modules/view/service';
import { ViewTargetTypeEnum } from 'src/modules/view/enums';
import { ItemStatusEnum } from 'src/modules/item/enums';
import * as dayjs from 'dayjs';
import { GeoJsonPoint, isValidGeoJsonPoint, toGeoJsonPoint } from 'src/shared/geo';
import { normalizeWorkshop, normalizeWorkshops } from '../utils/normalize-workshop';
import { PromoteWorkshopArgs } from '../dto/args/promote-workshop.args';
import { buildPromotionUpdate } from 'src/modules/service/utils/promotion';

const populate = [
  ...POPULATIONS.workshop,
  {
    path: 'categoryIds',
    model: COLLECTIONS.WORKSHOP_CATEGORIES,
    select: 'names slug icon color popular',
  },
];

@Injectable()
export class WorkshopService implements OnModuleInit {
  constructor(
    @InjectModel(COLLECTIONS.WORKSHOPS)
    private workshopModel: PaginateModel<Workshop>,
    private minioService: MinioService,
    private viewService: ViewService,
  ) {}

  async onModuleInit() {
    await this.workshopModel.updateMany(
      {
        $or: [
          { verified: { $exists: false } },
          { verified: null },
          { rating: { $exists: false } },
          { rating: null },
          { reviewCount: { $exists: false } },
          { gallery: { $exists: false } },
        ],
      },
      {
        $set: {
          verified: false,
          rating: 0,
          reviewCount: 0,
          fastResponse: false,
          bookingCount: 0,
          viewCount: 0,
          serviceRadiusKm: 15,
          servicePricing: [],
          weeklySchedule: [],
          premium: false,
          hasPickupService: false,
          open24Hours: false,
          isEmergency: false,
          supportedCarBrands: [],
        },
      },
    );

    await this.syncMapLocationFromGeo();
    await this.backfillMissingGeo();
    await this.repairInvalidMapLocations();
  }

  private async syncMapLocationFromGeo() {
    await this.workshopModel.collection.updateMany(
      {
        geo: { $exists: true, $ne: null },
        'geo.type': 'Point',
        'geo.coordinates.0': { $type: 'number' },
        'geo.coordinates.1': { $type: 'number' },
      },
      [{ $set: { mapLocation: '$geo' } }],
    );
  }

  /** Fixes null/legacy coordinates that break MongoDB 2dsphere queries. */
  private async repairInvalidMapLocations() {
    const broken = await this.workshopModel
      .find({
        mapLocation: { $exists: true, $ne: null },
        $nor: [
          {
            'mapLocation.type': 'Point',
            'mapLocation.coordinates.0': { $type: 'number' },
            'mapLocation.coordinates.1': { $type: 'number' },
          },
        ],
      })
      .select('_id geo mapLocation')
      .lean();

    for (const row of broken) {
      const geo = row.geo as GeoJsonPoint | undefined;
      if (isValidGeoJsonPoint(geo)) {
        await this.workshopModel.updateOne(
          { _id: row._id },
          { $set: { mapLocation: geo } },
        );
        continue;
      }

      const ml = row.mapLocation as
        | GeoJsonPoint
        | { latitude?: number; longitude?: number }
        | undefined;
      const legacyLat =
        ml && 'latitude' in ml ? (ml as { latitude?: number }).latitude : undefined;
      const legacyLng =
        ml && 'longitude' in ml ? (ml as { longitude?: number }).longitude : undefined;
      if (Number.isFinite(legacyLat) && Number.isFinite(legacyLng)) {
        const point = toGeoJsonPoint(legacyLat!, legacyLng!);
        await this.workshopModel.updateOne(
          { _id: row._id },
          { $set: { geo: point, mapLocation: point } },
        );
        continue;
      }

      await this.workshopModel.updateOne(
        { _id: row._id },
        { $unset: { mapLocation: '' } },
      );
    }
  }

  /** Legacy workshops had no GeoJSON — map queries skip them without coordinates. */
  private async backfillMissingGeo() {
    const withoutGeo = await this.workshopModel
      .find({
        $or: [
          { geo: { $exists: false } },
          { geo: null },
          { 'geo.coordinates': { $exists: false } },
          { 'geo.coordinates.0': { $exists: false } },
        ],
      })
      .select('_id')
      .lean();

    const baseLat = 41.2995;
    const baseLng = 69.2401;

    for (const row of withoutGeo) {
      const id = row._id.toString();
      let hash = 0;
      for (let i = 0; i < id.length; i++) {
        hash = (hash + id.charCodeAt(i)) % 10000;
      }
      const lat = baseLat + ((hash % 100) - 50) / 800;
      const lng = baseLng + ((Math.floor(hash / 100) % 100) - 50) / 800;

      await this.workshopModel.updateOne(
        { _id: row._id },
        {
          $set: {
            geo: toGeoJsonPoint(lat, lng),
            mapLocation: toGeoJsonPoint(lat, lng),
          },
        },
      );
    }
  }

  private mapGeo(data: { geoLocation: { latitude: number; longitude: number } }) {
    const { latitude, longitude } = data.geoLocation;
    return toGeoJsonPoint(latitude, longitude);
  }

  private enrich(doc: Workshop | null) {
    if (!doc) return doc;
    return normalizeWorkshop(doc);
  }

  async uploadImages(images: Promise<FileUpload>[]) {
    const uploadedImagesUrls: string[] = [];
    for (const image of images) {
      const file = await this.minioService.prepareFile({
        file: await image,
        compress: false,
      });
      const uploadedFileUrl = await this.minioService.uploadFile({
        ...file,
        catalog: Catalog.WORKSHOPS_IMAGES,
        compress: true,
      });
      uploadedImagesUrls.push(uploadedFileUrl);
    }
    return uploadedImagesUrls;
  }

  async uploadSingle(image?: Promise<FileUpload>) {
    if (!image) return '';
    const [url] = await this.uploadImages([image]);
    return url;
  }

  async createWorkshop(
    { data, gallery, coverImage, logo }: CreateWorkshopArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const galleryUrls = gallery?.length ? await this.uploadImages(gallery) : [];
    const coverUrl = await this.uploadSingle(coverImage);
    const logoUrl = await this.uploadSingle(logo);

    const categoryIds = (data.categoryIds ?? []).map(
      (id) => new Types.ObjectId(id),
    );

    const point = this.mapGeo(data);
    const createdWorkshop = await this.workshopModel.create({
      name: data.name,
      description: data.description ?? '',
      location: data.location ?? data.address ?? '',
      address: data.address ?? '',
      city: data.city ?? '',
      geo: point,
      mapLocation: point,
      serviceRadiusKm: data.serviceRadiusKm ?? 15,
      coverImage: coverUrl,
      logo: logoUrl,
      gallery: galleryUrls,
      images: galleryUrls,
      categoryIds,
      servicePricing: data.servicePricing ?? [],
      weeklySchedule: data.weeklySchedule ?? [],
      openFrom: data.openFrom,
      openUntil: data.openUntil ?? null,
      phone: data.phone ?? '',
      telegram: data.telegram ?? '',
      fastResponse: data.fastResponse ?? false,
      open24Hours: data.open24Hours ?? false,
      responseTimeMinutes: data.responseTimeMinutes ?? null,
      verified: false,
      rating: 0,
      reviewCount: 0,
      bookingCount: 0,
      viewCount: 0,
      status: ItemStatusEnum.ACTIVE,
      owner: new Types.ObjectId(userId),
      activeUntil: dayjs().add(1, 'month').toDate(),
    });

    const found = await this.workshopModel
      .findById(createdWorkshop._id)
      .populate(populate);
    return this.enrich(found);
  }

  async updateWorkshopById(
    { workshopId, data, images }: UpdateWorkshopByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const updateData: Record<string, unknown> = { ...data };

    if (data.geoLocation) {
      const geoPoint = this.mapGeo({ geoLocation: data.geoLocation });
      updateData.geo = geoPoint;
      updateData.mapLocation = geoPoint;
      delete updateData.geoLocation;
    }
    if (data.categoryIds) {
      updateData.categoryIds = data.categoryIds.map(
        (id) => new Types.ObjectId(id),
      );
    }

    if (data.gallery?.length) {
      updateData.gallery = data.gallery;
      updateData.images = data.gallery;
      if (!updateData.coverImage) {
        updateData.coverImage = data.gallery[0];
      }
    } else if (images?.length) {
      const imagesUrls = await this.uploadImages(images);
      updateData.gallery = imagesUrls;
      updateData.images = imagesUrls;
      if (!updateData.coverImage) {
        updateData.coverImage = imagesUrls[0];
      }
    }

    const updatedWorkshop = await this.workshopModel.findOneAndUpdate(
      { _id: workshopId, owner: new Types.ObjectId(userId) },
      { $set: updateData },
      { new: true },
    );

    if (!updatedWorkshop) {
      throw new BadRequestException('Workshop not found');
    }

    const found = await this.workshopModel
      .findById(updatedWorkshop._id)
      .populate(populate);
    return this.enrich(found);
  }

  async deleteWorkshopById(
    { workshopId }: GetWorkshopByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const deletedWorkshop = await this.workshopModel.findOneAndDelete({
      _id: workshopId,
      owner: new Types.ObjectId(userId),
    });

    if (!deletedWorkshop) {
      throw new BadRequestException('Workshop not found');
    }

    const urls = [
      ...(deletedWorkshop.gallery ?? []),
      ...(deletedWorkshop.images ?? []),
      deletedWorkshop.coverImage,
      deletedWorkshop.logo,
    ].filter(Boolean) as string[];

    if (urls.length) {
      await this.minioService.deleteFilesFromUrls(
        urls,
        new Array(urls.length).fill(true),
      );
    }

    return deletedWorkshop;
  }

  async getWorkshopById(
    { workshopId }: GetWorkshopByIdArgs,
    context: ContextType,
  ) {
    const foundWorkshop = await this.workshopModel
      .findById(workshopId)
      .populate(populate);

    if (!foundWorkshop) {
      throw new BadRequestException('Workshop not found');
    }

    const viewerId = context.userId;
    const isOwner =
      viewerId && foundWorkshop.owner?.toString() === viewerId.toString();

    if (!isOwner && foundWorkshop.status !== ItemStatusEnum.ACTIVE) {
      throw new BadRequestException('Workshop not found');
    }

    if (viewerId) {
      await this.viewService.incrementViewsCount(
        ViewTargetTypeEnum.WORKSHOP,
        foundWorkshop._id,
        viewerId,
      );
    }

    return this.enrich(foundWorkshop);
  }

  async getWorkshops(
    { pagination, filter, search }: GetWorkshopsArgs,
    context: ContextType,
  ) {
    const viewerId = context.userId;
    const queryFilter: RootFilterQuery<Workshop> = {};

    if (filter) {
      if (filter.owner) {
        queryFilter.owner = new Types.ObjectId(filter.owner);
      }
      if (filter.verified === true) queryFilter.verified = true;
      if (filter.fastResponse === true) queryFilter.fastResponse = true;
      if (filter.categoryId) {
        queryFilter.categoryIds = new Types.ObjectId(filter.categoryId);
      }
      if (filter.city?.trim()) {
        queryFilter.city = new RegExp(filter.city.trim(), 'i');
      }
    }

    const isOwnOwnerList =
      viewerId && filter?.owner?.toString() === viewerId.toString();

    if (!isOwnOwnerList) {
      queryFilter.status = ItemStatusEnum.ACTIVE;
    }

    if (search?.trim()) {
      const searchRegex = new RegExp(search.trim(), 'i');
      queryFilter.$or = [
        { name: searchRegex },
        { description: searchRegex },
        { address: searchRegex },
        { city: searchRegex },
        { location: searchRegex },
      ];
    }

    const { docs: foundWorkshops, ...paginationResult } =
      await this.workshopModel.paginate(queryFilter, {
        ...pagination,
        sort: {
          promotionPriority: -1,
          verified: -1,
          rating: -1,
          createdAt: -1,
        },
        populate,
      });

    let payload = normalizeWorkshops(foundWorkshops);

    if (filter?.openNow) {
      payload = payload.filter((w) => w.isOpenNow);
    }
    if (filter?.isOpen) {
      payload = payload.filter((w) => w.isOpenNow);
    }

    return {
      payload,
      ...paginationResult,
    };
  }

  async restoreWorkshopById(
    { workshopId }: GetWorkshopByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const restoredWorkshop = await this.workshopModel.findOneAndUpdate(
      { _id: workshopId, owner: new Types.ObjectId(userId) },
      {
        $set: {
          status: ItemStatusEnum.ACTIVE,
          activeUntil: dayjs().add(1, 'month').toDate(),
        },
      },
      { new: true },
    );

    if (!restoredWorkshop) {
      throw new BadRequestException('Workshop not found');
    }

    return this.enrich(restoredWorkshop);
  }

  async promoteWorkshop(
    { workshopId, plan }: PromoteWorkshopArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const promoted = await this.workshopModel.findOneAndUpdate(
      { _id: workshopId, owner: new Types.ObjectId(userId) },
      { $set: { ...buildPromotionUpdate(plan), premium: true } },
      { new: true },
    );
    if (!promoted) {
      throw new BadRequestException('Workshop not found');
    }
    return this.enrich(promoted);
  }
}
