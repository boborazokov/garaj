import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  OnModuleInit,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, PaginateModel, PipelineStage, RootFilterQuery, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { isAdminRole, ownerScope } from 'src/auth/utils/admin-scope';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { Part } from 'src/modules/part/schema';
import { PushService } from 'src/services/push';
import { SortOrderEnum } from 'src/shared/enums';
import { slugModelKey } from 'src/modules/category/seed/seed-vehicle-catalog';
import { ViewService } from 'src/modules/view/service';
import { ViewTargetTypeEnum } from 'src/modules/view/enums';
import {
  CreateOrderArgs,
  GetOrderByIdArgs,
  GetOrdersArgs,
  UpdateOrderByIdArgs,
} from '../dto';
import { OrderStatusEnum } from '../enums';
import { Order } from '../schema';
import {
  loadMockOrdersSeed,
  mockOrderCreatedAt,
  mockOrderToDoc,
} from '../seed/seed-mock-orders';
import { SellerMatchingOrdersOverview } from '../types';

const populate = [
  { path: 'author', model: COLLECTIONS.USERS },
  { path: 'brand', model: COLLECTIONS.CATEGORIES },
  { path: 'carModel', model: COLLECTIONS.CATEGORIES },
  { path: 'partCategory', model: COLLECTIONS.CATEGORIES },
];

@Injectable()
export class OrderService implements OnModuleInit {
  private readonly logger = new Logger(OrderService.name);

  constructor(
    @InjectModel(COLLECTIONS.ORDERS)
    private readonly orderModel: PaginateModel<Order>,
    @InjectModel(COLLECTIONS.PARTS)
    private readonly partModel: Model<Part>,
    private readonly pushService: PushService,
    private readonly viewService: ViewService,
  ) {}

  async onModuleInit() {
    try {
      const seeded = await this.seedMockOrders();
      if (seeded > 0) {
        this.logger.log(`Mock orders seeded: ${seeded}`);
      }
    } catch (err) {
      this.logger.warn(`Mock orders seed skipped: ${err}`);
    }
  }

  /** Idempotent demo buy-requests for admin / empty DB (upsert by title). */
  async seedMockOrders(): Promise<number> {
    // Re-run on boot to refresh demo fields (year, status, promotion).
    const rows = loadMockOrdersSeed();
    const author = await this.orderModel.db
      .collection(COLLECTIONS.USERS)
      .find({})
      .project({ _id: 1, phone: 1 })
      .sort({ createdAt: 1 })
      .limit(1)
      .next();
    if (!author?._id) {
      this.logger.warn('Skip mock orders seed: no users in database');
      return 0;
    }

    const categories = await this.orderModel.db
      .collection(COLLECTIONS.CATEGORIES)
      .find({
        type: {
          $in: [
            CategoryTypeEnum.BRAND,
            CategoryTypeEnum.MODEL,
            CategoryTypeEnum.PART,
          ],
        },
      })
      .project({ _id: 1, key: 1, type: 1, name: 1, names: 1, parentId: 1 })
      .toArray();

    const byKey = new Map(
      categories
        .filter((row) => typeof row.key === 'string' && row.key)
        .map((row) => [String(row.key), row]),
    );

    const authorId = new Types.ObjectId(String(author._id));
    let inserted = 0;

    for (const row of rows) {
      const brand = byKey.get(row.brandKey);
      const modelKey = slugModelKey(row.brandKey, row.modelName);
      const carModel =
        byKey.get(modelKey) ??
        categories.find(
          (item) =>
            item.type === CategoryTypeEnum.MODEL &&
            String(item.parentId ?? '') === String(brand?._id ?? '') &&
            String(item.names?.en ?? item.name ?? '').toLowerCase() ===
              row.modelName.toLowerCase(),
        );
      const partCategory = byKey.get(row.partCategoryKey);

      const doc = mockOrderToDoc(row, authorId, {
        brandId: brand?._id
          ? new Types.ObjectId(String(brand._id))
          : null,
        carModelId: carModel?._id
          ? new Types.ObjectId(String(carModel._id))
          : null,
        partCategoryId: partCategory?._id
          ? new Types.ObjectId(String(partCategory._id))
          : null,
      });

      const createdAt = mockOrderCreatedAt(row.daysAgo);
      const result = await this.orderModel.updateOne(
        { title: row.title },
        { $setOnInsert: doc },
        { upsert: true },
      );

      if (result.upsertedCount > 0) {
        inserted += 1;
        // Bypass mongoose timestamps middleware (conflicts with explicit updatedAt).
        await this.orderModel.collection.updateOne(
          { title: row.title },
          { $set: { createdAt, updatedAt: createdAt } },
        );
      } else {
        await this.orderModel.updateOne(
          { title: row.title },
          {
            $set: {
              description: doc.description,
              phone: doc.phone,
              location: doc.location,
              region: doc.region,
              brand: doc.brand,
              carModel: doc.carModel,
              partCategory: doc.partCategory,
              year: doc.year,
              budget: doc.budget,
              currency: doc.currency,
              urgency: doc.urgency,
              status: doc.status,
              isPromoted: doc.isPromoted,
              promotedUntil: doc.promotedUntil,
              promotionPlan: doc.promotionPlan,
              promotionPriority: doc.promotionPriority,
            },
          },
        );
        await this.orderModel.collection.updateOne(
          { title: row.title },
          { $set: { createdAt } },
        );
      }
    }

    return inserted;
  }

  async createOrder({ data }: CreateOrderArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const payload = {
      ...data,
      brand: data.brand ? new Types.ObjectId(data.brand) : null,
      carModel: data.carModel ? new Types.ObjectId(data.carModel) : null,
      partCategory: data.partCategory
        ? new Types.ObjectId(data.partCategory)
        : null,
      author: new Types.ObjectId(userId),
      status: OrderStatusEnum.ACTIVE,
    };

    const created = await this.orderModel.create(payload);

    void this.notifyMatchingSellers(created).catch((err) => {
      this.logger.warn(`Failed to notify matching sellers: ${err}`);
    });

    return created;
  }

  /**
   * Push + inbox alert for every seller who has an ACTIVE listing in the
   * same part category as the new buyer request.
   */
  private async notifyMatchingSellers(order: Order) {
    if (!order.partCategory) return;

    const categoryId = new Types.ObjectId(order.partCategory.toString());
    const authorId = order.author?.toString();

    const sellerIds = (await this.partModel.distinct('seller', {
      category: categoryId,
      status: ItemStatusEnum.ACTIVE,
      ...(authorId
        ? { seller: { $ne: new Types.ObjectId(authorId) } }
        : {}),
    })) as Types.ObjectId[];

    if (!sellerIds.length) return;

    let categoryName = '';
    try {
      const populated = await this.orderModel
        .findById(order._id)
        .populate({ path: 'partCategory', model: COLLECTIONS.CATEGORIES })
        .lean();
      const cat = populated?.partCategory as
        | { names?: { ru?: string; en?: string; uz?: string }; name?: string }
        | null
        | undefined;
      categoryName =
        cat?.names?.ru ||
        cat?.names?.en ||
        cat?.names?.uz ||
        cat?.name ||
        '';
    } catch {
      /* non-fatal */
    }

    await this.pushService.enqueueOrderMatched({
      recipientIds: sellerIds.map((id) => id.toString()),
      orderId: order._id.toString(),
      orderTitle: order.title || 'Buyer request',
      categoryName: categoryName || undefined,
      budget: order.budget ?? undefined,
      currency: order.currency ?? undefined,
    });
  }

  /** Categories the seller sells in + how many matching ACTIVE requests exist. */
  async getSellerMatchingOrdersOverview(
    context: ContextType,
  ): Promise<SellerMatchingOrdersOverview> {
    const { userId } = assertAuthenticated(context);
    const sellerOid = new Types.ObjectId(userId);

    const listingStats = await this.partModel.aggregate<{
      _id: Types.ObjectId;
      listingsCount: number;
    }>([
      {
        $match: {
          seller: sellerOid,
          status: ItemStatusEnum.ACTIVE,
          category: { $ne: null },
        },
      },
      { $group: { _id: '$category', listingsCount: { $sum: 1 } } },
    ]);

    if (!listingStats.length) {
      return { categories: [], totalMatchingOrders: 0 };
    }

    const categoryIds = listingStats.map((s) => s._id);
    const listingsByCat = new Map(
      listingStats.map((s) => [s._id.toString(), s.listingsCount]),
    );

    const orderStats = await this.orderModel.aggregate<{
      _id: Types.ObjectId;
      orderCount: number;
    }>([
      {
        $match: {
          status: OrderStatusEnum.ACTIVE,
          partCategory: { $in: categoryIds },
          author: { $ne: sellerOid },
        },
      },
      { $group: { _id: '$partCategory', orderCount: { $sum: 1 } } },
    ]);

    const orderCountByCat = new Map(
      orderStats.map((s) => [s._id.toString(), s.orderCount]),
    );

    const categoriesPopulated = await this.orderModel.db
      .collection(COLLECTIONS.CATEGORIES)
      .find({ _id: { $in: categoryIds } })
      .toArray();

    const catById = new Map(
      categoriesPopulated.map((c) => [c._id.toString(), c]),
    );

    const categories = categoryIds
      .map((id) => {
        const key = id.toString();
        return {
          categoryId: id,
          category: (catById.get(key) as unknown as SellerMatchingOrdersOverview['categories'][number]['category']) ?? null,
          orderCount: orderCountByCat.get(key) ?? 0,
          listingsCount: listingsByCat.get(key) ?? 0,
        };
      })
      .sort((a, b) => b.orderCount - a.orderCount || b.listingsCount - a.listingsCount);

    const totalMatchingOrders = categories.reduce(
      (sum, c) => sum + c.orderCount,
      0,
    );

    return { categories, totalMatchingOrders };
  }

  private async sellerCategoryIds(
    sellerId: Types.ObjectId,
  ): Promise<Types.ObjectId[]> {
    const ids = (await this.partModel.distinct('category', {
      seller: sellerId,
      status: ItemStatusEnum.ACTIVE,
      category: { $ne: null },
    })) as Types.ObjectId[];
    return ids.filter(Boolean);
  }

  async updateOrderById(
    { orderId, data }: UpdateOrderByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const updated = await this.orderModel.findOneAndUpdate(
      { _id: orderId, ...ownerScope(context, 'author', new Types.ObjectId(userId)) },
      { $set: data },
      { new: true },
    );

    if (!updated) {
      throw new BadRequestException('Order not found');
    }

    return updated;
  }

  async closeOrderById({ orderId }: GetOrderByIdArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const closed = await this.orderModel.findOneAndUpdate(
      { _id: orderId, ...ownerScope(context, 'author', new Types.ObjectId(userId)) },
      { $set: { status: OrderStatusEnum.CLOSED } },
      { new: true },
    );

    if (!closed) {
      throw new BadRequestException('Order not found');
    }

    return closed;
  }

  async reopenOrderById({ orderId }: GetOrderByIdArgs, context: ContextType) {
    const { userId } = assertAuthenticated(context);
    const reopened = await this.orderModel.findOneAndUpdate(
      {
        _id: orderId,
        ...ownerScope(context, 'author', new Types.ObjectId(userId)),
        status: OrderStatusEnum.CLOSED,
      },
      { $set: { status: OrderStatusEnum.ACTIVE } },
      { new: true },
    );

    if (!reopened) {
      throw new BadRequestException('Order not found or not closed');
    }

    return reopened;
  }

  async deleteOrderById(
    { orderId }: GetOrderByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const found = await this.orderModel.findById(orderId);
    if (!found) throw new BadRequestException('Order not found');
    if (
      !isAdminRole(context) &&
      found.author?.toString() !== userId.toString()
    ) {
      throw new ForbiddenException();
    }
    await this.orderModel.deleteOne({ _id: orderId });
    return found;
  }

  async getOrderById(
    { orderId, deviceId }: GetOrderByIdArgs,
    context: ContextType,
  ) {
    const found = await this.orderModel.findById(orderId).populate(populate);
    if (!found) throw new BadRequestException('Order not found');

    const viewerId = context.userId;
    const isAuthor =
      viewerId && found.author?.toString() === viewerId.toString();

    // Guests may view active and closed requests; only cancelled are hidden.
    if (!isAuthor && !isAdminRole(context) && found.status === OrderStatusEnum.CANCELLED) {
      throw new BadRequestException('Order not found');
    }

    if (!isAuthor && !isAdminRole(context)) {
      const normalizedDeviceId =
        deviceId?.trim() ||
        (viewerId ? `user:${viewerId.toString()}` : '');

      if (normalizedDeviceId) {
        const isNewView = await this.viewService.recordUniqueDeviceView({
          targetType: ViewTargetTypeEnum.ORDER,
          targetId: found._id,
          deviceId: normalizedDeviceId,
          userId: viewerId ?? null,
        });

        if (isNewView) {
          found.viewsCount = Number(found.viewsCount ?? 0) + 1;
          await this.orderModel.updateOne(
            { _id: found._id },
            { $inc: { viewsCount: 1 } },
          );
        }
      }
    }

    return found;
  }

  async recordOrderPhoneClick({ orderId }: GetOrderByIdArgs) {
    const updated = await this.orderModel
      .findByIdAndUpdate(orderId, { $inc: { phoneClickCount: 1 } }, { new: true })
      .populate(populate);
    if (!updated) throw new BadRequestException('Order not found');
    return updated;
  }

  async recordOrderShare({ orderId }: GetOrderByIdArgs) {
    const updated = await this.orderModel
      .findByIdAndUpdate(orderId, { $inc: { shareCount: 1 } }, { new: true })
      .populate(populate);
    if (!updated) throw new BadRequestException('Order not found');
    return updated;
  }

  private async buildFilterQuery(
    args: GetOrdersArgs,
    viewerUserId?: Types.ObjectId,
  ): Promise<RootFilterQuery<Order>> {
    const { filter, search } = args;
    const query: RootFilterQuery<Order> = {};

    if (filter) {
      if (filter.author) query.author = new Types.ObjectId(filter.author);
      if (filter.brand) query.brand = new Types.ObjectId(filter.brand);
      if (filter.carModel) query.carModel = new Types.ObjectId(filter.carModel);
      if (filter.partCategory)
        query.partCategory = new Types.ObjectId(filter.partCategory);
      if (filter.region) query.region = filter.region;
      if (filter.status) query.status = filter.status;
      if (filter.isPromoted !== undefined) {
        query.isPromoted = filter.isPromoted;
        if (filter.isPromoted) {
          query.promotedUntil = { $gt: new Date() } as never;
        }
      }

      if (filter.matchSellerCategories) {
        if (!viewerUserId) {
          // Unauthenticated callers never match seller inventory.
          query._id = { $exists: false };
        } else {
          const cats = await this.sellerCategoryIds(viewerUserId);
          if (!cats.length) {
            query._id = { $exists: false };
          } else if (!filter.partCategory) {
            query.partCategory = { $in: cats };
          }
          query.author = { $ne: viewerUserId };
        }
      }
    }

    // Hide closed/cancelled orders from third parties unless explicitly asked.
    const isOwnAuthorList =
      viewerUserId &&
      filter?.author?.toString() === viewerUserId.toString();

    if (!filter?.status && !isOwnAuthorList) {
      query.status = OrderStatusEnum.ACTIVE;
    }

    if (search) {
      const re = new RegExp(search, 'i');
      query.$or = [{ title: re }, { description: re }];
    }

    return query;
  }

  async getOrders(args: GetOrdersArgs, context: ContextType) {
    const { pagination, sort, viewerRegion } = args;
    const query = await this.buildFilterQuery(args, context.userId);
    const sortOrder = sort ?? SortOrderEnum.RECOMMENDED;

    if (sortOrder === SortOrderEnum.NEWEST) {
      const { docs, ...rest } = await this.orderModel.paginate(query, {
        ...pagination,
        sort: { createdAt: -1 },
        populate,
      });
      const payload = docs.filter((doc) => {
        const author = doc.author as { _id?: unknown } | Types.ObjectId | null;
        return author != null && typeof author === 'object' && '_id' in author;
      });
      return { payload, ...rest };
    }

    const now = new Date();
    const region = viewerRegion ?? null;
    const page = pagination?.page ?? 1;
    const limit = pagination?.limit ?? 10;

    const pipeline: PipelineStage[] = [
      { $match: query as Record<string, unknown> },
      {
        $addFields: {
          _promoActive: {
            $and: [
              { $eq: ['$isPromoted', true] },
              { $gt: ['$promotedUntil', now] },
            ],
          },
          _regionMatch: region
            ? { $eq: ['$region', region] }
            : { $literal: false },
        },
      },
      {
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
      },
      { $sort: { _rank: 1, promotionPriority: -1, createdAt: -1, _id: -1 } },
      {
        $facet: {
          meta: [{ $count: 'totalDocs' }],
          payload: [
            { $skip: (page - 1) * limit },
            { $limit: limit },
            {
              $lookup: {
                from: COLLECTIONS.USERS,
                localField: 'author',
                foreignField: '_id',
                as: 'author',
              },
            },
            { $unwind: { path: '$author', preserveNullAndEmptyArrays: true } },
            // Drop orphaned orders (deleted author) so GraphQL never resolves null User.
            { $match: { 'author._id': { $exists: true } } },
            {
              $lookup: {
                from: COLLECTIONS.CATEGORIES,
                localField: 'brand',
                foreignField: '_id',
                as: 'brand',
              },
            },
            { $unwind: { path: '$brand', preserveNullAndEmptyArrays: true } },
            {
              $lookup: {
                from: COLLECTIONS.CATEGORIES,
                localField: 'carModel',
                foreignField: '_id',
                as: 'carModel',
              },
            },
            {
              $unwind: {
                path: '$carModel',
                preserveNullAndEmptyArrays: true,
              },
            },
            {
              $lookup: {
                from: COLLECTIONS.CATEGORIES,
                localField: 'partCategory',
                foreignField: '_id',
                as: 'partCategory',
              },
            },
            {
              $unwind: {
                path: '$partCategory',
                preserveNullAndEmptyArrays: true,
              },
            },
            {
              $project: {
                _promoActive: 0,
                _regionMatch: 0,
                _rank: 0,
              },
            },
          ],
        },
      },
    ];

    const [result] = await this.orderModel.aggregate(pipeline).exec();

    const totalDocs = result?.meta?.[0]?.totalDocs ?? 0;
    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));
    const hasNextPage = page < totalPages;
    const hasPrevPage = page > 1;

    return {
      payload: result?.payload ?? [],
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
}
