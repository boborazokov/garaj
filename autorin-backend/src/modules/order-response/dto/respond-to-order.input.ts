import { Field, InputType } from '@nestjs/graphql';
import { IsOptional, MaxLength, Min } from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@InputType()
export class RespondToOrderInput {
  @Field(() => ObjectIdScalar)
  orderId: Types.ObjectId;

  @Field()
  @MaxLength(2000)
  text: string;

  @Field(() => ObjectIdScalar, { nullable: true })
  @IsOptional()
  partId?: Types.ObjectId;

  @Field({ nullable: true })
  @IsOptional()
  @Min(0)
  offeredPrice?: number;

  @Field({ nullable: true })
  @IsOptional()
  @Min(0)
  deliveryDays?: number;
}
