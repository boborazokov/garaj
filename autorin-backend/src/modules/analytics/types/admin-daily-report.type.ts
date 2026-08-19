import { Field, Int, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class AdminDailyReportRow {
  @Field()
  date: string;

  /** Unique users who opened the app / signed in this day */
  @Field(() => Int)
  visits: number;

  @Field(() => Int)
  newUsers: number;

  @Field(() => Int)
  partsPublished: number;

  @Field(() => Int)
  ordersPublished: number;
}

@ObjectType()
export class AdminDailyReport {
  @Field(() => [AdminDailyReportRow])
  rows: AdminDailyReportRow[];

  @Field(() => Int)
  days: number;

  @Field(() => Int)
  totalVisits: number;

  @Field(() => Int)
  totalNewUsers: number;

  @Field(() => Int)
  totalPartsPublished: number;

  @Field(() => Int)
  totalOrdersPublished: number;

  @Field(() => Int)
  todayVisits: number;

  @Field(() => Int)
  todayPartsPublished: number;
}
