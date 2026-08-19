import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { PaginateModel, Types } from 'mongoose';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { ContextType } from 'src/auth/interfaces';
import { COLLECTIONS } from 'src/constants';
import { POPULATIONS } from 'src/constants/populations.constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { AppSettingsService } from 'src/modules/app-settings/service';
import { Part } from 'src/modules/part/schema';
import { PartIndexService } from 'src/modules/search/service/part-index.service';
import { User } from 'src/modules/user/schema';
import { UserRoleEnum } from 'src/modules/user/enums';
import { PaginatedParts } from 'src/modules/part/types';
import { PaginatedUsers } from 'src/modules/user/types';
import { PaginatedOrders } from 'src/modules/order/types/paginated-orders.type';
import { Order } from 'src/modules/order/schema';
import { Category } from 'src/modules/category/schema';
import {
  AdminListOrdersArgs,
  AdminListPartsArgs,
  AdminListUsersArgs,
  AdminSetUserImageArgs,
  AdminSetUserVerifiedArgs,
  ModeratePartArgs,
  SetUserRoleArgs,
} from '../dto/args/admin.args';
import { AdminStats } from '../types/admin-stats.type';
import { AnalyticsService } from 'src/modules/analytics/service/analytics.service';
import { AdminDailyReport } from 'src/modules/analytics/types/admin-daily-report.type';
import { AdminDailyReportArgs } from '../dto/args/admin.args';
import { UserService } from 'src/modules/user/service';
import { PushService } from 'src/services/push';
import * as dayjs from 'dayjs';

@Injectable()
export class AdminService {
  constructor(
    @InjectModel(COLLECTIONS.USERS) private userModel: PaginateModel<User>,
    @InjectModel(COLLECTIONS.PARTS) private partModel: PaginateModel<Part>,
    @InjectModel(COLLECTIONS.ORDERS) private orderModel: PaginateModel<Order>,
    @InjectModel(COLLECTIONS.CATEGORIES)
    private categoryModel: PaginateModel<Category>,
    private appSettingsService: AppSettingsService,
    private partIndexService: PartIndexService,
    private analyticsService: AnalyticsService,
    private userService: UserService,
    private pushService: PushService,
  ) {}

  private assertAdmin(context: ContextType) {
    const { userRole } = assertAuthenticated(context);
    if (userRole !== UserRoleEnum.ADMIN) {
      throw new ForbiddenException('Admin access required');
    }
  }

  private assertModeratorOrAdmin(context: ContextType) {
    const { userRole } = assertAuthenticated(context);
    if (
      userRole !== UserRoleEnum.ADMIN &&
      userRole !== UserRoleEnum.MODERATOR
    ) {
      throw new ForbiddenException('Moderator access required');
    }
  }

  async getAppSettings(context: ContextType) {
    this.assertAdmin(context);
    return this.appSettingsService.getSettings();
  }

  async setProductModerationEnabled(enabled: boolean, context: ContextType) {
    this.assertAdmin(context);
    return this.appSettingsService.setProductModerationEnabled(enabled);
  }

  async getAdminDailyReport(
    args: AdminDailyReportArgs,
    context: ContextType,
  ): Promise<AdminDailyReport> {
    this.assertAdmin(context);
    const days = Math.min(Math.max(args.days ?? 14, 1), 90);
    return this.analyticsService.getAdminDailyReport(days);
  }

  async getAdminStats(context: ContextType): Promise<AdminStats> {
    this.assertAdmin(context);
    const [usersCount, partsCount, activePartsCount, pendingModerationCount, ordersCount] =
      await Promise.all([
        this.userModel.countDocuments(),
        this.partModel.countDocuments(),
        this.partModel.countDocuments({ status: ItemStatusEnum.ACTIVE }),
        this.partModel.countDocuments({
          status: ItemStatusEnum.PENDING_MODERATION,
        }),
        this.orderModel.countDocuments(),
      ]);

    return {
      usersCount,
      partsCount,
      activePartsCount,
      pendingModerationCount,
      ordersCount,
    };
  }

  async listUsers(
    args: AdminListUsersArgs,
    context: ContextType,
  ): Promise<PaginatedUsers> {
    this.assertAdmin(context);
    const { pagination, search } = args;
    const filter: Record<string, unknown> = {};
    if (search?.trim()) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ name: regex }, { phone: regex }];
    }

    const { docs, ...meta } = await this.userModel.paginate(filter, {
      ...pagination,
      sort: { createdAt: -1 },
      select: '-password',
    });

    return { payload: docs, ...meta };
  }

  async setUserRole(args: SetUserRoleArgs, context: ContextType) {
    this.assertAdmin(context);
    const { userId, role } = args;
    const { userId: actorId } = assertAuthenticated(context);

    if (userId.toString() === actorId.toString() && role !== UserRoleEnum.ADMIN) {
      throw new BadRequestException('Cannot demote yourself');
    }

    const updated = await this.userModel
      .findByIdAndUpdate(userId, { $set: { role } }, { new: true })
      .select('-password');

    if (!updated) {
      throw new BadRequestException('User not found');
    }

    return updated;
  }

  async setUserImage(args: AdminSetUserImageArgs, context: ContextType) {
    this.assertAdmin(context);
    return this.userService.setUserImageByAdmin(args.userId, args.image);
  }

  /**
   * Toggle the seller verification badge. Idempotent — re-setting the
   * same flag is a no-op but still returns the populated user so the
   * UI can refresh its row optimistically.
   *
   * When a user goes from `verified=false` → `verified=true`, we also
   * enqueue a push so they hear about it immediately (no need to wait
   * for them to reload their profile).
   */
  async setUserVerified(
    args: AdminSetUserVerifiedArgs,
    context: ContextType,
  ): Promise<User> {
    this.assertAdmin(context);
    const { userId, verified } = args;

    const target = await this.userModel.findById(userId).select('verified');
    if (!target) {
      throw new BadRequestException('User not found');
    }

    const updated = await this.userModel
      .findByIdAndUpdate(userId, { $set: { verified } }, { new: true })
      .select('-password');

    if (!updated) {
      throw new BadRequestException('User not found');
    }

    const wasNotVerified = target.verified !== true;
    if (verified && wasNotVerified) {
      void this.pushService.enqueueUserVerified({
        recipientIds: [userId.toString()],
        userId: userId.toString(),
      });
    }

    return updated;
  }

  async getPendingParts(
    args: AdminListPartsArgs,
    context: ContextType,
  ): Promise<PaginatedParts> {
    this.assertModeratorOrAdmin(context);
    const { pagination, search } = args;
    const filter: Record<string, unknown> = {
      status: ItemStatusEnum.PENDING_MODERATION,
    };
    if (search?.trim()) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ name: regex }, { description: regex }];
    }

    const { docs, ...meta } = await this.partModel.paginate(filter, {
      ...pagination,
      sort: { createdAt: 1 },
      populate: [...POPULATIONS.part, ...POPULATIONS.item],
    });

    return { payload: docs, ...meta };
  }

  async listAllParts(
    args: AdminListPartsArgs,
    context: ContextType,
  ): Promise<PaginatedParts> {
    this.assertAdmin(context);
    const { pagination, search, categoryType } = args;
    const filter: Record<string, unknown> = {};
    if (search?.trim()) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ name: regex }, { description: regex }];
    }

    if (categoryType) {
      const categories = await this.categoryModel
        .find({ type: categoryType })
        .select('_id')
        .lean();
      const categoryIds = categories.map((c) => c._id);
      filter.category = { $in: categoryIds.length ? categoryIds : [] };
    }

    const { docs, ...meta } = await this.partModel.paginate(filter, {
      ...pagination,
      sort: { createdAt: -1 },
      populate: [...POPULATIONS.part, ...POPULATIONS.item],
    });

    return { payload: docs, ...meta };
  }

  async listOrders(
    args: AdminListOrdersArgs,
    context: ContextType,
  ): Promise<PaginatedOrders> {
    this.assertAdmin(context);
    const { pagination, search } = args;
    const filter: Record<string, unknown> = {};
    if (search?.trim()) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [{ title: regex }, { description: regex }, { phone: regex }];
    }

    const { docs, ...meta } = await this.orderModel.paginate(filter, {
      ...pagination,
      sort: { createdAt: -1 },
      populate: [
        { path: 'author', model: COLLECTIONS.USERS, select: 'name phone' },
        { path: 'brand', model: COLLECTIONS.CATEGORIES, select: 'name' },
        { path: 'carModel', model: COLLECTIONS.CATEGORIES, select: 'name' },
        { path: 'partCategory', model: COLLECTIONS.CATEGORIES, select: 'name' },
      ],
    });

    return { payload: docs, ...meta };
  }

  async approvePart(args: ModeratePartArgs, context: ContextType) {
    this.assertModeratorOrAdmin(context);
    const { userId } = assertAuthenticated(context);
    const part = await this.partModel.findById(args.partId);

    if (!part || part.status !== ItemStatusEnum.PENDING_MODERATION) {
      throw new BadRequestException('Part is not pending moderation');
    }

    part.status = ItemStatusEnum.ACTIVE;
    part.activeUntil = dayjs().add(1, 'month').toDate();
    part.moderationNote = args.note ?? null;
    part.moderatedAt = new Date();
    part.moderatedBy = new Types.ObjectId(userId);
    await part.save();

    void this.partIndexService.indexPartById(part._id);
    return part;
  }

  async rejectPart(args: ModeratePartArgs, context: ContextType) {
    this.assertModeratorOrAdmin(context);
    const { userId } = assertAuthenticated(context);
    const part = await this.partModel.findById(args.partId);

    if (!part || part.status !== ItemStatusEnum.PENDING_MODERATION) {
      throw new BadRequestException('Part is not pending moderation');
    }

    if (!args.note?.trim()) {
      throw new BadRequestException('Rejection reason is required');
    }

    part.status = ItemStatusEnum.REJECTED;
    part.moderationNote = args.note.trim();
    part.moderatedAt = new Date();
    part.moderatedBy = new Types.ObjectId(userId);
    await part.save();

    void this.partIndexService.removePart(part._id);
    return part;
  }
}
