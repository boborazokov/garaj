import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { isAdminRole } from 'src/auth/utils/admin-scope';
import { COLLECTIONS } from 'src/constants';
import { PushService } from 'src/services/push';
import { CurrencyEnum } from 'src/shared/enums';
import {
  AdminCreditWalletArgs,
  AdminWalletTransactionsArgs,
  CreateWalletTopupIntentArgs,
  MyWalletTransactionsArgs,
} from '../dto';
import {
  WalletPoolEnum,
  WalletReferenceTypeEnum,
  WalletTransactionStatusEnum,
  WalletTransactionTypeEnum,
} from '../enums';
import { Wallet, WalletTransaction } from '../schema';

export type WalletView = Wallet & { availableTotal: number };

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name);

  constructor(
    @InjectModel(COLLECTIONS.WALLETS)
    private readonly walletModel: Model<Wallet>,
    @InjectModel(COLLECTIONS.WALLET_TRANSACTIONS)
    private readonly txModel: Model<WalletTransaction>,
    private readonly push: PushService,
  ) {}

  toView(wallet: Wallet): WalletView {
    return {
      ...wallet,
      availableTotal:
        (wallet.mainBalance ?? 0) + (wallet.bonusBalance ?? 0),
    };
  }

  async getOrCreate(userId: Types.ObjectId): Promise<Wallet> {
    const existing = await this.walletModel.findOne({ user: userId }).lean();
    if (existing) return existing as Wallet;

    try {
      const created = await this.walletModel.create({
        user: userId,
        mainBalance: 0,
        bonusBalance: 0,
        currency: CurrencyEnum.UZS,
      });
      return created.toObject() as Wallet;
    } catch {
      const raced = await this.walletModel.findOne({ user: userId }).lean();
      if (!raced) throw new BadRequestException('Could not create wallet');
      return raced as Wallet;
    }
  }

  async myWallet(context: ContextType): Promise<WalletView> {
    const { userId } = assertAuthenticated(context);
    const wallet = await this.getOrCreate(new Types.ObjectId(userId));
    return this.toView(wallet);
  }

  async adminWallet(
    userId: Types.ObjectId,
    context: ContextType,
  ): Promise<WalletView> {
    this.assertAdmin(context);
    const wallet = await this.getOrCreate(userId);
    return this.toView(wallet);
  }

  async myWalletTransactions(
    args: MyWalletTransactionsArgs,
    context: ContextType,
  ): Promise<WalletTransaction[]> {
    const { userId } = assertAuthenticated(context);
    return this.listTransactions({
      userId: new Types.ObjectId(userId),
      limit: args.limit,
      cursor: args.cursor,
    });
  }

  async adminWalletTransactions(
    args: AdminWalletTransactionsArgs,
    context: ContextType,
  ): Promise<WalletTransaction[]> {
    this.assertAdmin(context);
    return this.listTransactions({
      userId: args.userId,
      limit: args.limit,
      cursor: args.cursor,
    });
  }

  async listTransactions(params: {
    userId: Types.ObjectId;
    limit?: number;
    cursor?: Types.ObjectId;
  }): Promise<WalletTransaction[]> {
    const limit = Math.min(Math.max(params.limit ?? 30, 1), 100);
    const filter: Record<string, unknown> = { user: params.userId };
    if (params.cursor) {
      filter._id = { $lt: params.cursor };
    }
    return this.txModel
      .find(filter)
      .sort({ _id: -1 })
      .limit(limit)
      .lean() as Promise<WalletTransaction[]>;
  }

  /**
   * Mock top-up: create PENDING intent then immediately credit MAIN
   * (INTERNAL provider). Swap body for Payme/Click later.
   */
  async createWalletTopupIntent(
    args: CreateWalletTopupIntentArgs,
    context: ContextType,
  ): Promise<WalletTransaction> {
    const { userId } = assertAuthenticated(context);
    const amount = Math.floor(args.amount);
    if (!Number.isFinite(amount) || amount < 1_000) {
      throw new BadRequestException('Minimum top-up is 1000 UZS');
    }
    if (amount > 50_000_000) {
      throw new BadRequestException('Top-up amount too large');
    }

    const userObjectId = new Types.ObjectId(userId);
    const wallet = await this.getOrCreate(userObjectId);
    const intentId = new Types.ObjectId();

    const pending = await this.txModel.create({
      _id: intentId,
      wallet: wallet._id,
      user: userObjectId,
      type: WalletTransactionTypeEnum.TOPUP_MAIN,
      pool: WalletPoolEnum.MAIN,
      amount,
      balanceAfterMain: wallet.mainBalance,
      balanceAfterBonus: wallet.bonusBalance,
      status: WalletTransactionStatusEnum.PENDING,
      currency: CurrencyEnum.UZS,
      referenceType: WalletReferenceTypeEnum.TOPUP,
      referenceId: intentId,
      note: 'INTERNAL mock top-up',
      metaJson: JSON.stringify({ provider: 'INTERNAL' }),
    });

    try {
      const credited = await this.credit({
        userId: userObjectId,
        pool: WalletPoolEnum.MAIN,
        amount,
        type: WalletTransactionTypeEnum.TOPUP_MAIN,
        referenceType: WalletReferenceTypeEnum.TOPUP,
        referenceId: intentId,
        note: 'INTERNAL mock top-up',
        meta: { provider: 'INTERNAL', intentId: intentId.toString() },
      });
      await this.txModel.deleteOne({ _id: pending._id });
      this.notifyTopUp(userObjectId, amount, credited._id?.toString());
      return credited;
    } catch (err) {
      pending.status = WalletTransactionStatusEnum.FAILED;
      pending.note =
        err instanceof Error ? err.message : 'Top-up failed';
      await pending.save();
      throw err;
    }
  }

  async adminCreditWallet(
    args: AdminCreditWalletArgs,
    context: ContextType,
  ): Promise<WalletTransaction> {
    this.assertAdmin(context);
    const pool = args.pool;
    if (pool !== WalletPoolEnum.MAIN && pool !== WalletPoolEnum.BONUS) {
      throw new BadRequestException('Admin credit pool must be MAIN or BONUS');
    }
    const amount = Math.floor(args.amount);
    if (!Number.isFinite(amount) || amount < 1) {
      throw new BadRequestException('Amount must be a positive integer');
    }

    const type =
      pool === WalletPoolEnum.BONUS
        ? WalletTransactionTypeEnum.ADMIN_CREDIT_BONUS
        : WalletTransactionTypeEnum.ADMIN_TOPUP_MAIN;

    const credited = await this.credit({
      userId: args.userId,
      pool,
      amount,
      type,
      referenceType: WalletReferenceTypeEnum.ADMIN,
      referenceId: new Types.ObjectId(),
      note: args.note?.trim() || 'Admin credit',
      meta: { adminUserId: context.userId?.toString() },
    });
    this.notifyTopUp(args.userId, amount, credited._id?.toString());
    return credited;
  }

  /** Empty list stub — withdraw payouts not implemented in v1. */
  adminListWithdrawRequests(context: ContextType): WalletTransaction[] {
    this.assertAdmin(context);
    return [];
  }

  async debitForPromotion(params: {
    userId: Types.ObjectId;
    amount: number;
    promotionPaymentId: Types.ObjectId;
    plan?: string;
    targetType?: string;
  }): Promise<WalletTransaction> {
    const plan = (params.plan || 'TOP').toUpperCase();
    const target = (params.targetType || 'LISTING').toUpperCase();
    const reason = `Move to Top · ${plan} (${target})`;
    const tx = await this.debit({
      userId: params.userId,
      amount: params.amount,
      type: WalletTransactionTypeEnum.PROMOTION_SPEND,
      referenceType: WalletReferenceTypeEnum.PROMOTION_PAYMENT,
      referenceId: params.promotionPaymentId,
      note: reason,
      meta: { reasonCode: 'promotion', plan, targetType: target },
    });
    this.notifySpend(params.userId, params.amount, {
      reason,
      reasonCode: 'promotion',
      plan,
      txId: tx._id?.toString(),
    });
    return tx;
  }

  async debitForBooking(params: {
    userId: Types.ObjectId;
    amount: number;
    bookingId: Types.ObjectId;
  }): Promise<WalletTransaction> {
    const reason = 'Service booking fee';
    const tx = await this.debit({
      userId: params.userId,
      amount: params.amount,
      type: WalletTransactionTypeEnum.BOOKING_SPEND,
      referenceType: WalletReferenceTypeEnum.SERVICE_BOOKING,
      referenceId: params.bookingId,
      note: reason,
      meta: { reasonCode: 'booking' },
    });
    this.notifySpend(params.userId, params.amount, {
      reason,
      reasonCode: 'booking',
      txId: tx._id?.toString(),
    });
    return tx;
  }

  async debitForAdvertisement(params: {
    userId: Types.ObjectId;
    amount: number;
    advertisementId: Types.ObjectId;
    plan?: string;
    placement?: string;
  }): Promise<WalletTransaction> {
    const plan = (params.plan || 'WEEK').toUpperCase();
    const placement = (params.placement || 'PART').toUpperCase();
    const reason = `Banner ad · ${placement} · ${plan}`;
    const tx = await this.debit({
      userId: params.userId,
      amount: params.amount,
      type: WalletTransactionTypeEnum.ADVERTISEMENT_SPEND,
      referenceType: WalletReferenceTypeEnum.ADVERTISEMENT,
      referenceId: params.advertisementId,
      note: reason,
      meta: { reasonCode: 'advertisement', plan, placement },
    });
    this.notifySpend(params.userId, params.amount, {
      reason,
      reasonCode: 'advertisement',
      plan,
      txId: tx._id?.toString(),
    });
    return tx;
  }

  async credit(params: {
    userId: Types.ObjectId;
    pool: WalletPoolEnum.MAIN | WalletPoolEnum.BONUS;
    amount: number;
    type: WalletTransactionTypeEnum;
    referenceType?: WalletReferenceTypeEnum;
    referenceId?: Types.ObjectId;
    note?: string;
    meta?: Record<string, unknown>;
  }): Promise<WalletTransaction> {
    const amount = Math.floor(params.amount);
    if (amount < 1) {
      throw new BadRequestException('Credit amount must be positive');
    }

    if (params.referenceType && params.referenceId) {
      const existing = await this.findCompletedByReference(
        params.referenceType,
        params.referenceId,
        params.type,
      );
      if (existing) return existing;
    }

    await this.getOrCreate(params.userId);

    const inc =
      params.pool === WalletPoolEnum.BONUS
        ? { bonusBalance: amount }
        : { mainBalance: amount };

    const updated = await this.walletModel
      .findOneAndUpdate({ user: params.userId }, { $inc: inc }, { new: true })
      .lean();

    if (!updated) {
      throw new NotFoundException('Wallet not found');
    }

    return this.writeTx({
      walletId: updated._id as Types.ObjectId,
      userId: params.userId,
      type: params.type,
      pool: params.pool,
      amount,
      balanceAfterMain: updated.mainBalance,
      balanceAfterBonus: updated.bonusBalance,
      status: WalletTransactionStatusEnum.COMPLETED,
      referenceType: params.referenceType,
      referenceId: params.referenceId,
      note: params.note,
      meta: params.meta,
    });
  }

  /**
   * Spend bonus first, then main. Atomic via optimistic balance match + retry.
   */
  async debit(params: {
    userId: Types.ObjectId;
    amount: number;
    type: WalletTransactionTypeEnum;
    referenceType?: WalletReferenceTypeEnum;
    referenceId?: Types.ObjectId;
    note?: string;
    meta?: Record<string, unknown>;
  }): Promise<WalletTransaction> {
    const amount = Math.floor(params.amount);
    if (amount < 1) {
      throw new BadRequestException('Debit amount must be positive');
    }

    if (params.referenceType && params.referenceId) {
      const existing = await this.findCompletedByReference(
        params.referenceType,
        params.referenceId,
        params.type,
      );
      if (existing) return existing;
    }

    await this.getOrCreate(params.userId);

    for (let attempt = 0; attempt < 5; attempt++) {
      const wallet = await this.walletModel.findOne({ user: params.userId }).lean();
      if (!wallet) throw new NotFoundException('Wallet not found');

      const main = wallet.mainBalance ?? 0;
      const bonus = wallet.bonusBalance ?? 0;
      if (main + bonus < amount) {
        throw new BadRequestException('INSUFFICIENT_WALLET_BALANCE');
      }

      const fromBonus = Math.min(bonus, amount);
      const fromMain = amount - fromBonus;
      const pool =
        fromBonus > 0 && fromMain > 0
          ? WalletPoolEnum.SPLIT
          : fromBonus > 0
            ? WalletPoolEnum.BONUS
            : WalletPoolEnum.MAIN;

      const updated = await this.walletModel
        .findOneAndUpdate(
          {
            _id: wallet._id,
            mainBalance: main,
            bonusBalance: bonus,
          },
          {
            $inc: {
              mainBalance: -fromMain,
              bonusBalance: -fromBonus,
            },
          },
          { new: true },
        )
        .lean();

      if (!updated) continue;

      try {
        return await this.writeTx({
          walletId: updated._id as Types.ObjectId,
          userId: params.userId,
          type: params.type,
          pool,
          amount: -amount,
          balanceAfterMain: updated.mainBalance,
          balanceAfterBonus: updated.bonusBalance,
          status: WalletTransactionStatusEnum.COMPLETED,
          referenceType: params.referenceType,
          referenceId: params.referenceId,
          note: params.note,
          meta: {
            ...params.meta,
            fromBonus,
            fromMain,
          },
        });
      } catch (err) {
        // Unique reference race: roll balance back and return existing tx.
        await this.walletModel.updateOne(
          { _id: wallet._id },
          { $inc: { mainBalance: fromMain, bonusBalance: fromBonus } },
        );
        if (params.referenceType && params.referenceId) {
          const existing = await this.findCompletedByReference(
            params.referenceType,
            params.referenceId,
            params.type,
          );
          if (existing) return existing;
        }
        throw err;
      }
    }

    throw new BadRequestException('Could not debit wallet, please retry');
  }

  private async findCompletedByReference(
    referenceType: WalletReferenceTypeEnum,
    referenceId: Types.ObjectId,
    type: WalletTransactionTypeEnum,
  ): Promise<WalletTransaction | null> {
    return this.txModel
      .findOne({
        referenceType,
        referenceId,
        type,
        status: WalletTransactionStatusEnum.COMPLETED,
      })
      .lean() as Promise<WalletTransaction | null>;
  }

  private async writeTx(params: {
    walletId: Types.ObjectId;
    userId: Types.ObjectId;
    type: WalletTransactionTypeEnum;
    pool: WalletPoolEnum;
    amount: number;
    balanceAfterMain: number;
    balanceAfterBonus: number;
    status: WalletTransactionStatusEnum;
    referenceType?: WalletReferenceTypeEnum;
    referenceId?: Types.ObjectId;
    note?: string;
    meta?: Record<string, unknown>;
  }): Promise<WalletTransaction> {
    const doc = await this.txModel.create({
      wallet: params.walletId,
      user: params.userId,
      type: params.type,
      pool: params.pool,
      amount: params.amount,
      balanceAfterMain: params.balanceAfterMain,
      balanceAfterBonus: params.balanceAfterBonus,
      status: params.status,
      currency: CurrencyEnum.UZS,
      referenceType: params.referenceType ?? null,
      referenceId: params.referenceId ?? null,
      note: params.note ?? null,
      metaJson: params.meta ? JSON.stringify(params.meta) : null,
    });
    return doc.toObject() as WalletTransaction;
  }

  private assertAdmin(context: ContextType) {
    if (!isAdminRole(context)) {
      throw new ForbiddenException('Admin only');
    }
  }

  private notifyTopUp(
    userId: Types.ObjectId,
    amount: number,
    txId?: string,
  ) {
    void this.push
      .enqueueWalletTopUp({
        recipientIds: [userId.toString()],
        amount,
        currency: CurrencyEnum.UZS,
        txId,
      })
      .catch((err) =>
        this.logger.warn(`Failed to enqueue wallet top-up push: ${err}`),
      );
  }

  private notifySpend(
    userId: Types.ObjectId,
    amount: number,
    opts: {
      reason: string;
      reasonCode: string;
      plan?: string;
      txId?: string;
    },
  ) {
    void this.push
      .enqueueWalletSpend({
        recipientIds: [userId.toString()],
        amount,
        reason: opts.reason,
        reasonCode: opts.reasonCode,
        plan: opts.plan,
        currency: CurrencyEnum.UZS,
        txId: opts.txId,
      })
      .catch((err) =>
        this.logger.warn(`Failed to enqueue wallet spend push: ${err}`),
      );
  }
}
