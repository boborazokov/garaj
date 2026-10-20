import { Field, Int, ObjectType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { Category } from 'src/modules/category/schema';

@ObjectType()
export class SellerMatchingCategoryStat {
  @Field(() => ObjectIdScalar)
  categoryId: Types.ObjectId;

  @Field(() => Category, { nullable: true })
  category?: Category | null;

  @Field(() => Int)
  orderCount: number;

  @Field(() => Int)
  listingsCount: number;
}

@ObjectType()
export class SellerMatchingOrdersOverview {
  @Field(() => [SellerMatchingCategoryStat])
  categories: SellerMatchingCategoryStat[];

  @Field(() => Int)
  totalMatchingOrders: number;
}
