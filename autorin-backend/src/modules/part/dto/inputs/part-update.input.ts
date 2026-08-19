import { Field, InputType } from '@nestjs/graphql';
import { IsOptional, Min } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CurrencyEnum } from 'src/shared/enums';
import { DeliveryConditionEnum } from '../../enums';

@InputType()
export class PartUpdateInput {
  @Field({ nullable: true })
  name?: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  isNegotiable?: boolean;

  @Field(() => DeliveryConditionEnum, { nullable: true })
  deliveryCondition?: DeliveryConditionEnum;

  @Field({ nullable: true })
  isNew?: boolean;

  @Field({ nullable: true })
  @Min(0)
  @IsOptional()
  price?: number;

  @Field({ nullable: true })
  @Min(0)
  @IsOptional()
  quantity?: number;

  @Field(() => CurrencyEnum, { nullable: true })
  currency?: CurrencyEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  category?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  brand?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  carModel?: Types.ObjectId;

  @Field({ nullable: true })
  location?: string;

  @Field({ nullable: true })
  region?: string;
}
