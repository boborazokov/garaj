import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import type { RedisPubSub } from 'graphql-redis-subscriptions';
import { COLLECTIONS } from 'src/constants';
import { Order } from 'src/modules/order/schema';
import { Part } from 'src/modules/part/schema';
import { PUBSUB, TRIGGERS } from 'src/pubsub';
import { PushService } from 'src/services/push/push.service';
import { RespondToOrderInput } from '../dto/respond-to-order.input';
import { OrderResponse } from '../schema/order-response.schema';
import { UserRoleEnum } from 'src/modules/user/enums';
import { User } from 'src/modules/user/schema';

@Injectable()
export class OrderResponseService {
  private readonly logger = new Logger(OrderResponseService.name);

  constructor(
    @InjectModel(COLLECTIONS.ORDER_RESPONSES)
    private readonly responseModel: Model<OrderResponse>,
    @InjectModel(COLLECTIONS.ORDERS)
    private readonly orderModel: Model<Order>,
    @InjectModel(COLLECTIONS.PARTS)
    private readonly partModel: Model<Part>,
    @Inject(PUBSUB) private readonly pubSub: RedisPubSub,
    private readonly pushService: PushService,
  ) {}

  /** Order author or a seller who already responded may read responses / subscribe. */
  async canWatchOrder(
    userId: Types.ObjectId,
    orderId: Types.ObjectId,
  ): Promise<boolean> {
    const order = await this.orderModel.findById(orderId).select('author').lean();
    if (!order) throw new BadRequestException('Order not found');

    if (order.author?.toString() === userId.toString()) return true;

    return !!(await this.responseModel.exists({
      order: orderId,
      seller: userId,
    }));
  }

  async assertCanWatchOrder(userId: Types.ObjectId, orderId: Types.ObjectId) {
    if (!(await this.canWatchOrder(userId, orderId))) {
      throw new ForbiddenException('Not allowed to watch this order channel');
    }
  }

  async list(orderId: Types.ObjectId) {
    const rows = await this.responseModel
      .find({ order: orderId })
      .sort({ createdAt: -1 })
      .populate('seller', 'name phone role createdAt')
      .populate('part', 'name images price currency')
      .lean();
    return rows.map((row) =>
      this.presentResponse(row as unknown as Record<string, unknown>),
    );
  }

  async respond(sellerId: Types.ObjectId, input: RespondToOrderInput) {
    const order = await this.orderModel.findById(input.orderId);
    if (!order) throw new BadRequestException('Order not found');
    if (order.author?.toString() === sellerId.toString()) {
      throw new ForbiddenException('Cannot respond to your own request');
    }
    if (order.status !== 'ACTIVE') {
      throw new BadRequestException('Order is not open');
    }

    let partId: Types.ObjectId | null = null;
    if (input.partId) {
      const part = await this.partModel.findById(input.partId).select('seller').lean();
      if (!part) {
        throw new BadRequestException('Listing not found');
      }
      if (part.seller?.toString() !== sellerId.toString()) {
        throw new ForbiddenException('You can only link your own listing');
      }
      partId = input.partId;
    }

    const created = await this.responseModel.create({
      order: order._id,
      seller: sellerId,
      part: partId,
      text: input.text.trim(),
      offeredPrice: input.offeredPrice ?? null,
      deliveryDays: input.deliveryDays ?? null,
    });

    const populated = await this.responseModel
      .findById(created._id)
      .populate('seller', 'name phone role createdAt')
      .populate('part', 'name images price currency');

    if (!populated) {
      throw new BadRequestException('Failed to save response');
    }

    const presented = this.presentResponse(populated);
    const count = await this.responseModel.countDocuments({ order: order._id });

    try {
      await this.pubSub.publish(TRIGGERS.ORDER_RESPONSE_ADDED(order._id.toString()), {
        orderResponseAdded: presented,
      });
      await this.pubSub.publish(TRIGGERS.ORDER_UPDATED(order._id.toString()), {
        orderUpdated: {
          _id: order._id,
          status: order.status,
          responseCount: count,
        },
      });
    } catch (err) {
      this.logger.warn(`Order response publish failed: ${err}`);
    }

    const authorId = order.author?.toString();
    if (authorId) {
      const seller = presented.seller as User | undefined;
      const replierName = seller?.name?.trim() || 'Seller';
      try {
        await this.pushService.enqueueOrderReply({
          recipientIds: [authorId],
          orderId: order._id.toString(),
          orderTitle: (order.title ?? 'Your request').toString(),
          replierName,
          responsePreview: input.text.trim(),
        });
      } catch (err) {
        this.logger.warn(`Order reply push enqueue failed: ${err}`);
      }
    }

    return presented;
  }

  /**
   * GraphQL `User` requires name, phone, role, password and createdAt.
   * Populate only loads a subset, so fill the required fields before return.
   * Otherwise the mutation errors after the offer is saved and the app
   * keeps showing "0 offers".
   */
  private presentResponse(raw: { toObject?: () => Record<string, unknown> } | Record<string, unknown>) {
    const obj: Record<string, any> =
      raw && typeof (raw as { toObject?: () => Record<string, unknown> }).toObject === 'function'
        ? (raw as { toObject: () => Record<string, unknown> }).toObject()
        : { ...(raw as Record<string, unknown>) };

    const seller = obj.seller;
    if (seller && typeof seller === 'object') {
      obj.seller = {
        _id: seller._id,
        name: String(seller.name ?? '').trim() || 'Seller',
        phone: seller.phone ? String(seller.phone) : '',
        role: seller.role ?? UserRoleEnum.USER,
        password: '',
        createdAt: seller.createdAt ?? obj.createdAt ?? new Date(),
      };
    }

    const part = obj.part;
    if (!part || typeof part !== 'object' || !part._id || !part.name) {
      obj.part = null;
    }

    return obj;
  }
}
