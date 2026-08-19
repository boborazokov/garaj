import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { PaginationInput } from 'src/shared/inputs';

@ArgsType()
export class GetSellerFollowersArgs {
  @Field(() => ObjectIdScalar)
  sellerId: Types.ObjectId;

  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;
}
