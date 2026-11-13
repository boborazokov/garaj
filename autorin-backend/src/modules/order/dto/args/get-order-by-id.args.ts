import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class GetOrderByIdArgs {
  @Field(() => ObjectIdScalar)
  orderId: Types.ObjectId;

  /** Client install id — used so one device counts as one order view. */
  @Field(() => String, { nullable: true })
  deviceId?: string;
}
