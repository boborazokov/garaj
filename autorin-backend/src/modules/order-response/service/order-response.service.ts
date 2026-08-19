import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
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
import { User } from 'src/modules/user/schema';

@Injectable()
export class OrderResponseService {
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
    return this.responseModel
      .find({ order: orderId })
      .sort({ createdAt: -1 })
      .populate('seller', 'name phone role')
      .populate('part', 'name images price currency seller')
      .lean();
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
      .populate('seller', 'name phone role')
      .populate('part', 'name images price currency seller');

    if (!populated) {
      throw new BadRequestException('Failed to save response');
    }

    const count = await this.responseModel.countDocuments({ order: order._id });

    await this.pubSub.publish(TRIGGERS.ORDER_RESPONSE_ADDED(order._id.toString()), {
      orderResponseAdded: populated.toObject(),
    });

    await this.pubSub.publish(TRIGGERS.ORDER_UPDATED(order._id.toString()), {
      orderUpdated: {
        _id: order._id,
        status: order.status,
        responseCount: count,
      },
    });

    const authorId = order.author?.toString();
    if (authorId) {
      const seller = populated.seller as User | undefined;
      const replierName = seller?.name?.trim() || 'Seller';
      await this.pushService.enqueueOrderReply({
        recipientIds: [authorId],
        orderId: order._id.toString(),
        orderTitle: (order.title ?? 'Your request').toString(),
        replierName,
        responsePreview: input.text.trim(),
      });
    }

    return populated;
  }
}
