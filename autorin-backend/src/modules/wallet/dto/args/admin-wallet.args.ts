import { ArgsType, Field, Int } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class AdminWalletArgs {
  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;
}

@ArgsType()
export class AdminWalletTransactionsArgs {
  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;

  @Field(() => Int, { nullable: true, defaultValue: 30 })
  limit?: number;

  @Field(() => ObjectIdScalar, { nullable: true })
  cursor?: Types.ObjectId;
}
