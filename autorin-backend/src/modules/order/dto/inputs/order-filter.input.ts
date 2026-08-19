import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { OrderStatusEnum } from '../../enums';

@InputType()
export class OrderFilterInput {
  @Field(() => ObjectIdScalar, { nullable: true })
  author?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  brand?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  carModel?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  partCategory?: Types.ObjectId;

  @Field({ nullable: true })
  region?: string;

  @Field(() => OrderStatusEnum, { nullable: true })
  status?: OrderStatusEnum;

  @Field({ nullable: true })
  isPromoted?: boolean;
}
