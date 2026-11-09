import { ArgsType, Field, Int } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { WalletPoolEnum } from '../../enums';

@ArgsType()
export class AdminCreditWalletArgs {
  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;

  @Field(() => WalletPoolEnum)
  pool: WalletPoolEnum;

  @Field(() => Int)
  amount: number;

  @Field(() => String, { nullable: true })
  note?: string;
}
