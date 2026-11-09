import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { isAdminRole } from 'src/auth/utils/admin-scope';
import { COLLECTIONS } from 'src/constants';
import { Order } from 'src/modules/order/schema';
import { Part } from 'src/modules/part/schema';
import { AutoService } from 'src/modules/service/schema/service.schema';
import {
  PROMOTION_PLAN_DAYS,
  PROMOTION_PLAN_WEIGHT,
  ServicePromotionPlanEnum,
} from 'src/modules/service/enums/service-promotion-plan.enum';
import { buildPromotionUpdate } from 'src/modules/service/utils/promotion';
import { Workshop } from 'src/modules/workshop/schema';
import { CurrencyEnum } from 'src/shared/enums';
import { PROMOTION_PLAN_PRICES_UZS } from '../constants/plan-prices';
import {
  AdminFulfillPromotionArgs,
  AdminRetryPromotionPaymentArgs,
  PurchasePromotionArgs,
} from '../dto';
import {
  PromotionPaymentStatusEnum,
  PromotionTargetTypeEnum,
} from '../enums';
import { PromotionPayment, PromotionPlanPrice } from '../schema';

type OwnerField = 'seller' | 'author' | 'owner';

@Injectable()
export class PromotionPaymentService {
  constructor(
    @InjectModel(COLLECTIONS.PROMOTION_PAYMENTS)
    private readonly paymentModel: Model<PromotionPayment>,
    @InjectModel(COLLECTIONS.PARTS)
    private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.ORDERS)
    private readonly orderModel: Model<Order>,
    @InjectModel(COLLECTIONS.SERVICES)
    private readonly serviceModel: Model<AutoService>,
    @InjectModel(COLLECTIONS.WORKSHOPS)
    private readonly workshopModel: Model<Workshop>,
  ) {}

  getPlanPrices(): PromotionPlanPrice[] {
    return Object.values(ServicePromotionPlanEnum).map((plan) => ({
      plan,
      amount: PROMOTION_PLAN_PRICES_UZS[plan],
      currency: CurrencyEnum.UZS,
      days: PROMOTION_PLAN_DAYS[plan],
      priority: PROMOTION_PLAN_WEIGHT[plan],
    }));
  }

  /**
   * User path: pick plan → pay → listing floats to top.
   * Until a real gateway is wired, payment is recorded and marked PAID
   * immediately (INTERNAL provider), then promotion is applied.
   */
  async purchasePromotion(
    args: PurchasePromotionArgs,
    context: ContextType,
  ): Promise<PromotionPayment> {
    const { userId } = assertAuthenticated(context);
    const userObjectId = new Types.ObjectId(userId);
    const { targetType, targetId, plan } = args;

    await this.assertOwnsTarget(targetType, targetId, userObjectId);

    const amount = PROMOTION_PLAN_PRICES_UZS[plan];
    if (!amount || amount <= 0) {
      throw new BadRequestException('Invalid promotion plan');
    }

    const payment = await this.paymentModel.create({
      user: userObjectId,
      targetType,
      targetId,
      plan,
      amount,
      currency: CurrencyEnum.UZS,
      status: PromotionPaymentStatusEnum.PENDING,
      provider: 'INTERNAL',
      providerRef: null,
      paidAt: null,
      promotedAt: null,
      failureReason: null,
    });

    try {
      // Placeholder for Payme/Click charge. INTERNAL always succeeds.
      const providerRef = `internal_${payment._id.toString()}`;
      payment.providerRef = providerRef;
      payment.status = PromotionPaymentStatusEnum.PAID;
      payment.paidAt = new Date();
      await payment.save();
    } catch (err) {
      payment.status = PromotionPaymentStatusEnum.FAILED;
      payment.failureReason =
        err instanceof Error ? err.message : 'Payment charge failed';
      await payment.save();
      throw new BadRequestException(
        'Payment failed. If money was deducted, contact support — an admin can promote manually.',
      );
    }

    try {
      await this.applyPromotion(targetType, targetId, plan);
      payment.promotedAt = new Date();
      payment.failureReason = null;
      await payment.save();
    } catch (err) {
      payment.failureReason =
        err instanceof Error
          ? err.message
          : 'Paid but promote failed — admin can fulfill';
      await payment.save();
      throw new BadRequestException(
        'Payment succeeded but promotion failed. Contact support — an admin can move it to top.',
      );
    }

    return payment;
  }

  /** Admin: force-boost a listing when auto-promote after pay failed. */
  async adminFulfillPromotion(
    args: AdminFulfillPromotionArgs,
    context: ContextType,
  ): Promise<boolean> {
    this.assertAdmin(context);
    const plan = args.plan ?? ServicePromotionPlanEnum.VIP;
    await this.applyPromotion(args.targetType, args.targetId, plan);

    await this.paymentModel.findOneAndUpdate(
      {
        targetType: args.targetType,
        targetId: args.targetId,
        status: PromotionPaymentStatusEnum.PAID,
        promotedAt: null,
      },
      {
        $set: {
          promotedAt: new Date(),
          failureReason: null,
          plan,
        },
      },
      { sort: { createdAt: -1 } },
    );

    return true;
  }

  /** Admin: retry boost for a specific PAID payment that never promoted. */
  async adminRetryPromotionPayment(
    args: AdminRetryPromotionPaymentArgs,
    context: ContextType,
  ): Promise<PromotionPayment> {
    this.assertAdmin(context);
    const payment = await this.paymentModel.findById(args.paymentId);
    if (!payment) {
      throw new NotFoundException('Promotion payment not found');
    }
    if (payment.status !== PromotionPaymentStatusEnum.PAID) {
      throw new BadRequestException('Only PAID payments can be retried');
    }
    if (payment.promotedAt) {
      return payment;
    }

    await this.applyPromotion(
      payment.targetType,
      payment.targetId,
      payment.plan,
    );
    payment.promotedAt = new Date();
    payment.failureReason = null;
    await payment.save();
    return payment;
  }

  private assertAdmin(context: ContextType) {
    assertAuthenticated(context);
    if (!isAdminRole(context)) {
      throw new ForbiddenException('Admin only');
    }
  }

  private async assertOwnsTarget(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
    userId: Types.ObjectId,
  ) {
    const { model, ownerField } = this.targetModel(targetType);
    const doc = await model
      .findById(targetId)
      .select({ [ownerField]: 1 })
      .lean();
    if (!doc) {
      throw new NotFoundException('Listing not found');
    }
    const owner = (doc as Record<string, unknown>)[ownerField];
    const ownerId =
      owner instanceof Types.ObjectId
        ? owner
        : owner && typeof owner === 'object' && '_id' in (owner as object)
          ? (owner as { _id: Types.ObjectId })._id
          : null;
    if (!ownerId || ownerId.toString() !== userId.toString()) {
      throw new ForbiddenException('You can only promote your own listings');
    }
  }

  private targetModel(targetType: PromotionTargetTypeEnum): {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    model: Model<any>;
    ownerField: OwnerField;
  } {
    switch (targetType) {
      case PromotionTargetTypeEnum.PART:
        return { model: this.partModel, ownerField: 'seller' };
      case PromotionTargetTypeEnum.ORDER:
        return { model: this.orderModel, ownerField: 'author' };
      case PromotionTargetTypeEnum.SERVICE:
        return { model: this.serviceModel, ownerField: 'owner' };
      case PromotionTargetTypeEnum.WORKSHOP:
        return { model: this.workshopModel, ownerField: 'owner' };
      default:
        throw new BadRequestException('Unsupported promotion target');
    }
  }

  private async applyPromotion(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
    plan: ServicePromotionPlanEnum,
  ) {
    const update = buildPromotionUpdate(plan);

    switch (targetType) {
      case PromotionTargetTypeEnum.PART: {
        const updated = await this.partModel.findByIdAndUpdate(
          targetId,
          { $set: update },
          { new: true },
        );
        if (!updated) throw new NotFoundException('Part not found');
        return;
      }
      case PromotionTargetTypeEnum.ORDER: {
        const updated = await this.orderModel.findByIdAndUpdate(
          targetId,
          { $set: update },
          { new: true },
        );
        if (!updated) throw new NotFoundException('Order not found');
        return;
      }
      case PromotionTargetTypeEnum.SERVICE: {
        const updated = await this.serviceModel.findByIdAndUpdate(
          targetId,
          { $set: update },
          { new: true },
        );
        if (!updated) throw new NotFoundException('Service not found');
        return;
      }
      case PromotionTargetTypeEnum.WORKSHOP: {
        const updated = await this.workshopModel.findByIdAndUpdate(
          targetId,
          { $set: { ...update, premium: true } },
          { new: true },
        );
        if (!updated) throw new NotFoundException('Workshop not found');
        return;
      }
      default:
        throw new BadRequestException('Unsupported promotion target');
    }
  }
}
