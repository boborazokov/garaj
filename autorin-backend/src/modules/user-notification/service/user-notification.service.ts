import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { LIMIT_DEFAULT, PAGE_DEFAULT, PaginationInput } from 'src/shared/inputs';
import { UserNotification } from '../schema/user-notification.schema';
import { PaginatedUserNotifications, UserNotificationType } from '../types';

@Injectable()
export class UserNotificationService {
  constructor(
    @InjectModel(COLLECTIONS.USER_NOTIFICATIONS)
    private readonly model: Model<UserNotification>,
  ) {}

  async createForUsers(
    userIds: string[],
    input: {
      type: string;
      title: string;
      body: string;
      deepLink?: string;
      data?: Record<string, string>;
    },
  ): Promise<void> {
    const docs = userIds
      .filter((id) => Types.ObjectId.isValid(id))
      .map((id) => ({
        userId: new Types.ObjectId(id),
        type: input.type,
        title: input.title,
        body: input.body,
        deepLink: input.deepLink,
        data: input.data ?? {},
      }));

    if (!docs.length) return;
    await this.model.insertMany(docs);
  }

  async listForUser(
    userId: string,
    pagination?: PaginationInput,
  ): Promise<PaginatedUserNotifications> {
    const page = Math.max(1, pagination?.page ?? PAGE_DEFAULT);
    const limit = Math.min(50, Math.max(1, pagination?.limit ?? LIMIT_DEFAULT));
    const filter = { userId: new Types.ObjectId(userId) };

    const [totalDocs, docs] = await Promise.all([
      this.model.countDocuments(filter),
      this.model
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean()
        .exec(),
    ]);

    const totalPages = Math.max(1, Math.ceil(totalDocs / limit));

    return {
      payload: docs.map((doc) => this.toGraph(doc)),
      totalDocs,
      limit,
      page,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
      prevPage: page > 1 ? page - 1 : undefined,
      nextPage: page < totalPages ? page + 1 : undefined,
    };
  }

  async unreadCount(userId: string): Promise<number> {
    return this.model.countDocuments({
      userId: new Types.ObjectId(userId),
      $or: [{ readAt: null }, { readAt: { $exists: false } }],
    });
  }

  async markRead(userId: string, notificationId: string): Promise<boolean> {
    if (!Types.ObjectId.isValid(notificationId)) return false;
    const res = await this.model.updateOne(
      {
        _id: new Types.ObjectId(notificationId),
        userId: new Types.ObjectId(userId),
        $or: [{ readAt: null }, { readAt: { $exists: false } }],
      },
      { $set: { readAt: new Date() } },
    );
    return res.modifiedCount > 0;
  }

  async markAllRead(userId: string): Promise<number> {
    const res = await this.model.updateMany(
      {
        userId: new Types.ObjectId(userId),
        $or: [{ readAt: null }, { readAt: { $exists: false } }],
      },
      { $set: { readAt: new Date() } },
    );
    return res.modifiedCount;
  }

  private toGraph(doc: {
    _id: Types.ObjectId;
    type: string;
    title: string;
    body: string;
    deepLink?: string;
    readAt?: Date | null;
    createdAt: Date;
  }): UserNotificationType {
    return {
      _id: doc._id,
      type: doc.type,
      title: doc.title,
      body: doc.body,
      deepLink: doc.deepLink,
      isRead: doc.readAt != null,
      createdAt: doc.createdAt,
    };
  }
}
