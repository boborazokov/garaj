import { Field, InputType, Int } from '@nestjs/graphql';
import { IsOptional, Max, MaxLength, Min, MinLength } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { OrderUrgencyEnum } from '../../enums';

@InputType()
export class OrderInput {
  @Field()
  @MinLength(2)
  @MaxLength(120)
  title: string;

  @Field({ nullable: true })
  @IsOptional()
  @MaxLength(2000)
  description?: string;

  @Field()
  @MinLength(7)
  phone: string;

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

  @Field(() => Int, { nullable: true })
  @IsOptional()
  @Min(1950)
  @Max(2100)
  year?: number;

  @Field({ nullable: true })
  budget?: number;

  @Field({ nullable: true })
  currency?: string;

  @Field(() => OrderUrgencyEnum, { nullable: true })
  @IsOptional()
  urgency?: OrderUrgencyEnum;
}
