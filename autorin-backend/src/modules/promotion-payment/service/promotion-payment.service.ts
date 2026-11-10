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
import {
  buildPromotionClearUpdate,
  buildPromotionUpdate,
} from 'src/modules/service/utils/promotion';
import { Workshop } from 'src/modules/workshop/schema';
import { CurrencyEnum } from 'src/shared/enums';
import { WalletService } from 'src/modules/wallet/service';
import { AppSettingsService } from 'src/modules/app-settings/service';
import { PROMOTION_PLAN_PRICES_UZS } from '../constants/plan-prices';
import {
  AdminFulfillPromotionArgs,
  AdminRetryPromotionPaymentArgs,
  CancelPromotionArgs,
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
    private readonly walletService: WalletService,
    private readonly appSettingsService: AppSettingsService,
  ) {}

  async getPlanPrices(): Promise<PromotionPlanPrice[]> {
    const [overrides, dayOverrides, discounts] = await Promise.all([
      this.appSettingsService.getPromotionTariffs(),
      this.appSettingsService.getPromotionTariffDays(),
      this.appSettingsService.getPromotionTariffDiscounts(),
    ]);
    return Object.values(ServicePromotionPlanEnum).map((plan) => ({
      plan,
      amount:
        typeof overrides[plan] === 'number'
          ? overrides[plan]
          : PROMOTION_PLAN_PRICES_UZS[plan],
      currency: CurrencyEnum.UZS,
      days:
        typeof dayOverrides[plan] === 'number'
          ? dayOverrides[plan]
          : PROMOTION_PLAN_DAYS[plan],
      priority: PROMOTION_PLAN_WEIGHT[plan],
      discountPercent:
        typeof discounts[plan] === 'number' ? discounts[plan] : 0,
    }));
  }

  async daysForPlan(plan: ServicePromotionPlanEnum): Promise<number> {
    const overrides = await this.appSettingsService.getPromotionTariffDays();
    if (typeof overrides[plan] === 'number') return overrides[plan];
    return PROMOTION_PLAN_DAYS[plan];
  }

  async priceForPlan(plan: ServicePromotionPlanEnum): Promise<number> {
    const overrides = await this.appSettingsService.getPromotionTariffs();
    const amount =
      typeof overrides[plan] === 'number'
        ? overrides[plan]
        : PROMOTION_PLAN_PRICES_UZS[plan];
    if (amount == null || amount < 0) {
      throw new BadRequestException('Invalid promotion plan');
    }
    return amount;
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

    const amount = await this.priceForPlan(plan);
    if (amount <= 0) {
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
      const walletTx = await this.walletService.debitForPromotion({
        userId: userObjectId,
        amount,
        promotionPaymentId: payment._id,
        plan,
        targetType,
      });
      payment.provider = 'WALLET';
      payment.providerRef = walletTx._id.toString();
      payment.status = PromotionPaymentStatusEnum.PAID;
      payment.paidAt = new Date();
      await payment.save();
    } catch (err) {
      payment.status = PromotionPaymentStatusEnum.FAILED;
      const message =
        err instanceof Error ? err.message : 'Payment charge failed';
      payment.failureReason = message;
      await payment.save();
      if (message === 'INSUFFICIENT_WALLET_BALANCE') {
        throw new BadRequestException(
          'INSUFFICIENT_WALLET_BALANCE: Top up your wallet to promote this listing.',
        );
      }
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

  /**
   * Admin Top / recommend: charge the listing owner's wallet, then caller
   * applies the boost. Fails with INSUFFICIENT_WALLET_BALANCE if empty.
   */
  async adminChargeOwnerForBoost(params: {
    targetType: PromotionTargetTypeEnum;
    targetId: Types.ObjectId;
    plan?: ServicePromotionPlanEnum;
    context: ContextType;
  }): Promise<PromotionPayment> {
    this.assertAdmin(params.context);
    const plan = params.plan ?? ServicePromotionPlanEnum.TOP;
    const amount = await this.priceForPlan(plan);
    if (amount <= 0) {
      throw new BadRequestException('Invalid promotion plan');
    }

    const ownerId = await this.resolveOwnerId(
      params.targetType,
      params.targetId,
    );

    const payment = await this.paymentModel.create({
      user: ownerId,
      targetType: params.targetType,
      targetId: params.targetId,
      plan,
      amount,
      currency: CurrencyEnum.UZS,
      status: PromotionPaymentStatusEnum.PENDING,
      provider: 'WALLET_ADMIN',
      providerRef: null,
      paidAt: null,
      promotedAt: null,
      failureReason: null,
    });

    try {
      const walletTx = await this.walletService.debitForPromotion({
        userId: ownerId,
        amount,
        promotionPaymentId: payment._id,
        plan,
        targetType: params.targetType,
      });
      payment.providerRef = walletTx._id.toString();
      payment.status = PromotionPaymentStatusEnum.PAID;
      payment.paidAt = new Date();
      await payment.save();
      return payment;
    } catch (err) {
      payment.status = PromotionPaymentStatusEnum.FAILED;
      const message =
        err instanceof Error ? err.message : 'Wallet charge failed';
      payment.failureReason = message;
      await payment.save();
      if (message === 'INSUFFICIENT_WALLET_BALANCE') {
        throw new BadRequestException(
          'INSUFFICIENT_WALLET_BALANCE: Owner wallet has insufficient funds for Top.',
        );
      }
      throw new BadRequestException(message);
    }
  }

  async markPromotionPaymentPromoted(paymentId: Types.ObjectId) {
    await this.paymentModel.findByIdAndUpdate(paymentId, {
      $set: { promotedAt: new Date(), failureReason: null },
    });
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

  private async resolveOwnerId(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
  ): Promise<Types.ObjectId> {
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
    if (!ownerId) {
      throw new BadRequestException('Listing owner not found');
    }
    return ownerId;
  }

  private async assertOwnsTarget(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
    userId: Types.ObjectId,
  ) {
    const ownerId = await this.resolveOwnerId(targetType, targetId);
    if (ownerId.toString() !== userId.toString()) {
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

  /**
   * Owner turns off an active boost. No wallet refund.
   */
  async cancelPromotion(
    args: CancelPromotionArgs,
    context: ContextType,
  ): Promise<boolean> {
    const { userId } = assertAuthenticated(context);
    const userObjectId = new Types.ObjectId(userId);
    await this.assertOwnsTarget(args.targetType, args.targetId, userObjectId);
    await this.clearPromotion(args.targetType, args.targetId);
    return true;
  }

  private async readCurrentPromotedUntil(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
  ): Promise<Date | null> {
    const { model } = this.targetModel(targetType);
    const doc = await model
      .findById(targetId)
      .select({ promotedUntil: 1 })
      .lean();
    if (!doc) return null;
    const raw = (doc as { promotedUntil?: Date | string | null }).promotedUntil;
    if (!raw) return null;
    const date = raw instanceof Date ? raw : new Date(raw);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  private async applyPromotion(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
    plan: ServicePromotionPlanEnum,
  ) {
    const currentUntil = await this.readCurrentPromotedUntil(
      targetType,
      targetId,
    );
    const days = await this.daysForPlan(plan);
    const update = buildPromotionUpdate(plan, currentUntil, days);

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

  private async clearPromotion(
    targetType: PromotionTargetTypeEnum,
    targetId: Types.ObjectId,
  ) {
    const update = buildPromotionClearUpdate();

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
          { $set: { ...update, premium: false } },
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
