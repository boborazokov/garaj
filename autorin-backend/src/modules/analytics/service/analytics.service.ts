import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as dayjs from 'dayjs';
import { COLLECTIONS } from 'src/constants';
import { DailyUserVisit } from '../schema/daily-user-visit.schema';
import { User } from 'src/modules/user/schema';
import { Part } from 'src/modules/part/schema';
import {
  AdminDailyReport,
  AdminDailyReportRow,
} from '../types/admin-daily-report.type';

const REPORT_TIMEZONE = 'Asia/Tashkent';

function formatDayInTz(date: Date): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: REPORT_TIMEZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectModel(COLLECTIONS.DAILY_USER_VISITS)
    private readonly visitModel: Model<DailyUserVisit>,
    @InjectModel(COLLECTIONS.USERS) private readonly userModel: Model<User>,
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.ORDERS) private readonly orderModel: Model<unknown>,
    @InjectModel(COLLECTIONS.USER_ACTIVITIES)
    private readonly activityModel: Model<{ userId?: Types.ObjectId; createdAt: Date }>,
  ) {}

  /** Current calendar day key in Tashkent. */
  dayKey(date = new Date()): string {
    return formatDayInTz(date);
  }

  /** Records a daily visit (idempotent per user/day). */
  async recordVisit(userId: Types.ObjectId | string): Promise<void> {
    const uid =
      typeof userId === 'string' ? new Types.ObjectId(userId) : userId;
    const day = this.dayKey();
    try {
      await this.visitModel.updateOne(
        { userId: uid, day },
        { $setOnInsert: { userId: uid, day } },
        { upsert: true },
      );
    } catch {
      // duplicate key — already counted today
    }
  }

  private buildDayRange(days: number): string[] {
    const count = Math.min(Math.max(days, 1), 90);
    const keys: string[] = [];
    for (let i = count - 1; i >= 0; i--) {
      keys.push(formatDayInTz(dayjs().subtract(i, 'day').toDate()));
    }
    return keys;
  }

  private async countByCreatedAtDay(
    model: Model<unknown>,
    since: Date,
  ): Promise<Map<string, number>> {
    const rows = await model.aggregate<{ _id: string; count: number }>([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt',
              timezone: REPORT_TIMEZONE,
            },
          },
          count: { $sum: 1 },
        },
      },
    ]);
    return new Map(rows.map((r) => [r._id, r.count]));
  }

  private async visitsByDay(since: Date): Promise<Map<string, number>> {
    const fromDay = dayjs(since).format('YYYY-MM-DD');
    const visitRows = await this.visitModel.aggregate<{ _id: string; count: number }>([
      { $match: { day: { $gte: fromDay } } },
      { $group: { _id: '$day', count: { $sum: 1 } } },
    ]);

    const map = new Map(visitRows.map((r) => [r._id, r.count]));

    // Backfill older days from activity (before visit tracking existed)
    const activityRows = await this.activityModel.aggregate<{
      _id: string;
      count: number;
    }>([
      {
        $match: {
          createdAt: { $gte: since },
          userId: { $exists: true, $ne: null },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt',
              timezone: REPORT_TIMEZONE,
            },
          },
          users: { $addToSet: '$userId' },
        },
      },
      { $project: { _id: 1, count: { $size: '$users' } } },
    ]);

    for (const row of activityRows) {
      const existing = map.get(row._id) ?? 0;
      if (row.count > existing) {
        map.set(row._id, row.count);
      }
    }

    return map;
  }

  async getAdminDailyReport(days = 14): Promise<AdminDailyReport> {
    const dayKeys = this.buildDayRange(days);
    const since = dayjs().subtract(days - 1, 'day').startOf('day').toDate();

    const [visitsMap, newUsersMap, partsMap, ordersMap] = await Promise.all([
      this.visitsByDay(since),
      this.countByCreatedAtDay(this.userModel, since),
      this.countByCreatedAtDay(this.partModel, since),
      this.countByCreatedAtDay(this.orderModel, since),
    ]);

    const rows: AdminDailyReportRow[] = dayKeys.map((date) => ({
      date,
      visits: visitsMap.get(date) ?? 0,
      newUsers: newUsersMap.get(date) ?? 0,
      partsPublished: partsMap.get(date) ?? 0,
      ordersPublished: ordersMap.get(date) ?? 0,
    }));

    const today = this.dayKey();
    const sum = (pick: (r: AdminDailyReportRow) => number) =>
      rows.reduce((acc, r) => acc + pick(r), 0);

    return {
      rows,
      days,
      totalVisits: sum((r) => r.visits),
      totalNewUsers: sum((r) => r.newUsers),
      totalPartsPublished: sum((r) => r.partsPublished),
      totalOrdersPublished: sum((r) => r.ordersPublished),
      todayVisits: visitsMap.get(today) ?? 0,
      todayPartsPublished: partsMap.get(today) ?? 0,
    };
  }
}
