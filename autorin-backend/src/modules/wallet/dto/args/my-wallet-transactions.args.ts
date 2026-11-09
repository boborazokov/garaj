import { ArgsType, Field, Int } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@ArgsType()
export class MyWalletTransactionsArgs {
  @Field(() => Int, { nullable: true, defaultValue: 30 })
  limit?: number;

  @Field(() => ObjectIdScalar, { nullable: true })
  cursor?: Types.ObjectId;
}
