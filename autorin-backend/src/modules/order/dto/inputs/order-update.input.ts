import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { OrderStatusEnum, OrderUrgencyEnum } from '../../enums';

@InputType()
export class OrderUpdateInput {
  @Field({ nullable: true })
  title?: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  location?: string;

  @Field({ nullable: true })
  region?: string;

  @Field(() => ObjectIdScalar, { nullable: true })
  brand?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  carModel?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  partCategory?: Types.ObjectId;

  @Field({ nullable: true })
  budget?: number;

  @Field({ nullable: true })
  currency?: string;

  @Field(() => OrderStatusEnum, { nullable: true })
  status?: OrderStatusEnum;

  @Field(() => OrderUrgencyEnum, { nullable: true })
  urgency?: OrderUrgencyEnum;
}
