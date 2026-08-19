import { BadRequestException, Inject, Injectable, forwardRef } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Catalog, COLLECTIONS } from 'src/constants';
import { Favorite } from 'src/modules/favorite/schema';
import { Part } from '../schema';
import { PaginateModel, PipelineStage, RootFilterQuery, Types } from 'mongoose';
import {
  CreatePartArgs,
  GetPartByIdArgs,
  GetPartsArgs,
  PromotePartArgs,
  UpdatePartByIdArgs,
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
import { SortOrderEnum } from 'src/shared/enums';
import { PartIndexService } from 'src/modules/search/service/part-index.service';
import { RecommendationService } from 'src/modules/recommendation/service/recommendation.service';
import { AppSettingsService } from 'src/modules/app-settings/service/app-settings.service';
import { buildPromotionUpdate } from 'src/modules/service/utils/promotion';

@Injectable()
export class PartService {
  constructor(
    @InjectModel(COLLECTIONS.PARTS) private partModel: PaginateModel<Part>,
    @InjectModel(COLLECTIONS.FAVORITES) private favoriteModel: PaginateModel<Favorite>,
    private minioService: MinioService,
    private viewService: ViewService,
    private partIndexService: PartIndexService,
    private appSettingsService: AppSettingsService,
    @Inject(forwardRef(() => RecommendationService))
    private recommendationService: RecommendationService,
  ) {}

  /**
   * GraphQL exposes `Part.isPromoted` as non-null; older Mongo documents may
   * omit the field so the driver yields `undefined` and GraphQL aborts.
   */
  private partForGraphql(part: unknown): Part {
    if (part == null || typeof part !== 'object') {
      return part as Part;
    }
    const doc = part as Record<string, unknown> & {
      toObject?: (opts?: object) => Record<string, unknown>;
    };
    const plain =
      typeof doc.toObject === 'function'
        ? doc.toObject({ virtuals: true })
        : { ...doc };
    return {
      ...plain,
      isPromoted: plain.isPromoted === true,
      promotionPriority: (plain.promotionPriority as number) ?? 0,
    } as Part;
  }

  async uploadPartImages(
    images: Promise<FileUpload>[],
    oldImagesUrls?: string[],
  ) {
    if (oldImagesUrls) {
      for (const oldImageUrl of oldImagesUrls) {
        await this.minioService.deleteFileFromUrl(oldImageUrl);
      }
    }

    const uploadedImagesUrls: string[] = [];

    for (const image of images) {
      const file = await this.minioService.prepareFile({
        file: await image,
        compress: false,
      });

      const uploadedFileUrl = await this.minioService.uploadFile({
        ...file,
        catalog: Catalog.PARTS_IMAGES,
        compress: true,
      });

      uploadedImagesUrls.push(uploadedFileUrl);
    }

    return uploadedImagesUrls;
  }

  async createPart({ data, images }: CreatePartArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const imagesUrls = await this.uploadPartImages(images);
    const moderationEnabled =
      await this.appSettingsService.isProductModerationEnabled();

    const status = moderationEnabled
      ? ItemStatusEnum.PENDING_MODERATION
      : ItemStatusEnum.ACTIVE;

    const partData = {
      ...data,
      images: imagesUrls,
      status,
      seller: new Types.ObjectId(userId),
      activeUntil:
        status === ItemStatusEnum.ACTIVE
          ? dayjs().add(1, 'month').toDate()
          : undefined,
    };

    const created = await this.partModel.create(partData);
    if (status === ItemStatusEnum.ACTIVE) {
      void this.partIndexService.indexPartById(created._id);
    }
    return this.partForGraphql(created);
  }

  async updatePartById(
    { partId, data, images }: UpdatePartByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const updateData: Partial<Part> = data;

    if (images?.length) {
      if (updateData.images) {
        await this.minioService.deleteFilesFromUrls(
          updateData.images,
          new Array(updateData.images.length).fill(true),
        );
      }

      const imagesUrls = await this.uploadPartImages(images);

      if (imagesUrls) {
        updateData.images = imagesUrls;
      }
    }

    const updatedPart = await this.partModel.findOneAndUpdate(
      { _id: partId, seller: new Types.ObjectId(userId) },
      { $set: updateData },
      { new: true },
    );

    if (!updatedPart) {
      throw new BadRequestException('Part not found');
    }

    void this.partIndexService.indexPartById(updatedPart._id);
    return this.partForGraphql(updatedPart);
  }

  async deletePartById({ partId }: GetPartByIdArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const deletedPart = await this.partModel.findOneAndDelete({
      _id: partId,
      seller: new Types.ObjectId(userId),
    });

    if (!deletedPart) {
      throw new BadRequestException('Part not found');
    }

    if (deletedPart.images) {
      await this.minioService.deleteFilesFromUrls(
        deletedPart.images,
        new Array(deletedPart.images.length).fill(true),
      );
    }

    void this.partIndexService.removePart(partId);
    return this.partForGraphql(deletedPart);
  }

  async getPartById({ partId }: GetPartByIdArgs, context: ContextType) {
    const foundPart = await this.partModel
      .findById(partId)
      .populate([...POPULATIONS.part, ...POPULATIONS.item]);

    if (!foundPart) {
      throw new BadRequestException('Part not found');
    }

    const viewerId = context.userId;
    const isOwner =
      viewerId && foundPart.seller?.toString() === viewerId.toString();

    if (!isOwner && foundPart.status !== ItemStatusEnum.ACTIVE) {
      throw new BadRequestException('Part not found');
    }

    if (viewerId) {
      await this.viewService.incrementViewsCount(
        ViewTargetTypeEnum.PART,
        foundPart._id,
        viewerId,
      );
    }

    void this.recommendationService.trackProductView(context, foundPart._id, true);

    return this.partForGraphql(foundPart);
  }

  /**
   * Build the Mongo filter shared by getParts/aggregate.
   * Encapsulates the policy that other-sellers' archived items are hidden.
   */
  private async buildFilterQuery(
    args: GetPartsArgs,
    viewerUserId?: Types.ObjectId,
  ): Promise<RootFilterQuery<Part>> {
    const { filter, search } = args;
    const queryFilter: RootFilterQuery<Part> = {};

    if (filter?.onlyFavorites) {
      if (!viewerUserId) {
        queryFilter._id = { $in: [] } as never;
        return queryFilter;
      }
      const fav = await this.favoriteModel
        .findOne({ userId: viewerUserId })
        .select('partsIds')
        .lean();
      const ids = fav?.partsIds ?? [];
      queryFilter._id = { $in: ids.length ? ids : [] } as never;
    }

    if (filter) {
      if (filter.seller) queryFilter.seller = new Types.ObjectId(filter.seller);
      if (filter.category) queryFilter.category = new Types.ObjectId(filter.category);
      if (filter.brand) queryFilter.brand = new Types.ObjectId(filter.brand);
      if (filter.carModel) queryFilter.carModel = new Types.ObjectId(filter.carModel);
      if (filter.isNegotiable !== undefined) queryFilter.isNegotiable = filter.isNegotiable;
      if (filter.isNew !== undefined) queryFilter.isNew = filter.isNew;
      if (filter.currency) queryFilter.currency = filter.currency;
      if (filter.region) queryFilter.region = filter.region;
      if (filter.isPromoted !== undefined) {
        queryFilter.isPromoted = filter.isPromoted;
        if (filter.isPromoted) {
          queryFilter.promotedUntil = { $gt: new Date() } as never;
        }
      }

      const priceRange: Record<string, number> = {};
      if (filter.minPrice !== undefined) priceRange.$gte = filter.minPrice;
      if (filter.maxPrice !== undefined) priceRange.$lte = filter.maxPrice;
      if (Object.keys(priceRange).length) {
        (queryFilter as Record<string, unknown>).price = priceRange;
      }
    }

    const isOwnSellerList =
      viewerUserId &&
      filter?.seller?.toString() === viewerUserId.toString();

    if (!isOwnSellerList) {
      queryFilter.status = ItemStatusEnum.ACTIVE;
    }

    if (search) {
      const searchRegex = new RegExp(search, 'i');
      queryFilter.$or = [{ name: searchRegex }, { description: searchRegex }];
    }

    return queryFilter;
  }

  async getParts(args: GetPartsArgs, context: ContextType) {
    const { pagination, sort, viewerRegion } = args;
    const queryFilter = await this.buildFilterQuery(args, context.userId);

    const sortOrder = sort ?? SortOrderEnum.RECOMMENDED;

    // Simple sorts can use the paginate plugin directly.
    if (
      sortOrder === SortOrderEnum.NEWEST ||
      sortOrder === SortOrderEnum.PRICE_ASC ||
      sortOrder === SortOrderEnum.PRICE_DESC
    ) {
      const sortSpec: Record<string, 1 | -1> =
        sortOrder === SortOrderEnum.NEWEST
          ? { createdAt: -1 }
          : sortOrder === SortOrderEnum.PRICE_ASC
            ? { price: 1 }
            : { price: -1 };

      const { docs, ...paginationResult } = await this.partModel.paginate(
        queryFilter,
        {
          ...pagination,
          sort: sortSpec,
          populate: [...POPULATIONS.part, ...POPULATIONS.item],
        },
      );
      return {
        payload: docs.map((d) => this.partForGraphql(d)),
        ...paginationResult,
      };
    }

    // RECOMMENDED ordering: promoted-in-region → promoted-global → newest.
    // Done via aggregation so the rank is computed on the DB side.
    const now = new Date();
    const region = viewerRegion ?? null;
    const page = pagination?.page ?? 1;
    const limit = pagination?.limit ?? 10;

    const matchStage: PipelineStage = { $match: queryFilter as Record<string, unknown> };

    const addRankStage: PipelineStage = {
      $addFields: {
        _promoActive: {
          $and: [
            { $eq: ['$isPromoted', true] },
            { $gt: ['$promotedUntil', now] },
          ],
        },
        _regionMatch: region ? { $eq: ['$region', region] } : { $literal: false },
      },
    };

    const rankStage: PipelineStage = {
      $addFields: {
        _rank: {
          $switch: {
            branches: [
              {
                case: { $and: ['$_promoActive', '$_regionMatch'] },
                then: 0,
              },
              { case: '$_promoActive', then: 1 },
            ],
            default: 2,
          },
        },
      },
    };

    const sortStage: PipelineStage = {
      $sort: {
        _rank: 1,
        promotionPriority: -1,
        createdAt: -1,
        _id: -1,
      },
    };

    const facetStage: PipelineStage = {
      $facet: {
        meta: [{ $count: 'totalDocs' }],
        payload: [
          { $skip: (page - 1) * limit },
          { $limit: limit },
          {
            $lookup: {
              from: COLLECTIONS.USERS,
              localField: 'seller',
              foreignField: '_id',
              as: 'seller',
            },
          },
          { $unwind: { path: '$seller', preserveNullAndEmptyArrays: true } },
          {
            $lookup: {
              from: COLLECTIONS.CATEGORIES,
              localField: 'category',
              foreignField: '_id',
              as: 'category',
            },
          },
          { $unwind: { path: '$category', preserveNullAndEmptyArrays: true } },
          {
            $project: {
              _promoActive: 0,
              _regionMatch: 0,
              _rank: 0,
            },
          },
        ],
      },
    };

    const [result] = await this.partModel
      .aggregate([matchStage, addRankStage, rankStage, sortStage, facetStage])
      .exec();

    const totalDocs = result?.meta?.[0]?.totalDocs ?? 0;
    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));
    const hasNextPage = page < totalPages;
    const hasPrevPage = page > 1;

    return {
      payload: (result?.payload ?? []).map((d) => this.partForGraphql(d)),
      totalDocs,
      limit,
      page,
      totalPages,
      hasNextPage,
      hasPrevPage,
      nextPage: hasNextPage ? page + 1 : null,
      prevPage: hasPrevPage ? page - 1 : null,
    };
  }

  async restorePartById({ partId }: GetPartByIdArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const restoredPart = await this.partModel.findOneAndUpdate(
      { _id: partId, seller: new Types.ObjectId(userId) },
      {
        $set: {
          status: ItemStatusEnum.ACTIVE,
          activeUntil: dayjs().add(1, 'month').toDate(),
        },
      },
      { new: true },
    );

    if (!restoredPart) {
      throw new BadRequestException('Part not found');
    }

    return this.partForGraphql(restoredPart);
  }

  async promotePartById(
    { partId, plan }: PromotePartArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);

    const promoted = await this.partModel.findOneAndUpdate(
      { _id: partId, seller: new Types.ObjectId(userId) },
      { $set: buildPromotionUpdate(plan) },
      { new: true },
    );

    if (!promoted) {
      throw new BadRequestException('Part not found');
    }

    return this.partForGraphql(promoted);
  }
}
