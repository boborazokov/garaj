import { Field, InputType } from '@nestjs/graphql';
import { Min } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CurrencyEnum } from 'src/shared/enums';
import { DeliveryConditionEnum } from '../../enums';

@InputType()
export class PartInput {
  @Field()
  name: string;

  @Field()
  description: string;

  @Field()
  isNegotiable: boolean;

  @Field(() => DeliveryConditionEnum)
  deliveryCondition: DeliveryConditionEnum;

  @Field()
  isNew: boolean;

  @Field()
  @Min(0)
  price: number;

  @Field()
  @Min(0)
  quantity: number;

  @Field(() => CurrencyEnum)
  currency: CurrencyEnum;

  @Field(() => ObjectIdScalar)
  category: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  brand?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  carModel?: Types.ObjectId;

  @Field({ nullable: true })
  location?: string;

  @Field({ nullable: true })
  region?: string;
}
