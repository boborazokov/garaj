import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { PaginateModel, PipelineStage, RootFilterQuery, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { COLLECTIONS } from 'src/constants';
import { SortOrderEnum } from 'src/shared/enums';
import {
  CreateOrderArgs,
  GetOrderByIdArgs,
  GetOrdersArgs,
  UpdateOrderByIdArgs,
} from '../dto';
import { OrderStatusEnum } from '../enums';
import { Order } from '../schema';

const populate = [
  { path: 'author', model: COLLECTIONS.USERS },
  { path: 'brand', model: COLLECTIONS.CATEGORIES },
  { path: 'carModel', model: COLLECTIONS.CATEGORIES },
  { path: 'partCategory', model: COLLECTIONS.CATEGORIES },
];

@Injectable()
export class OrderService {
  constructor(
    @InjectModel(COLLECTIONS.ORDERS)
    private readonly orderModel: PaginateModel<Order>,
  ) {}

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

    return this.orderModel.create(payload);
  }

  async updateOrderById(
    { orderId, data }: UpdateOrderByIdArgs,
    context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    const updated = await this.orderModel.findOneAndUpdate(
      { _id: orderId, author: new Types.ObjectId(userId) },
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
      { _id: orderId, author: new Types.ObjectId(userId) },
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
        author: new Types.ObjectId(userId),
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
    if (found.author?.toString() !== userId.toString()) {
      throw new ForbiddenException();
    }
    await this.orderModel.deleteOne({ _id: orderId });
    return found;
  }

  async getOrderById({ orderId }: GetOrderByIdArgs, context: ContextType) {
    const found = await this.orderModel.findById(orderId).populate(populate);
    if (!found) throw new BadRequestException('Order not found');

    const viewerId = context.userId;
    const isAuthor =
      viewerId && found.author?.toString() === viewerId.toString();

    // Guests may view active and closed requests; only cancelled are hidden.
    if (!isAuthor && found.status === OrderStatusEnum.CANCELLED) {
      throw new BadRequestException('Order not found');
    }

    return found;
  }

  private buildFilterQuery(
    args: GetOrdersArgs,
    viewerUserId?: Types.ObjectId,
  ): RootFilterQuery<Order> {
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
    const query = this.buildFilterQuery(args, context.userId);
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
      { $sort: { _rank: 1, createdAt: -1, _id: -1 } },
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
