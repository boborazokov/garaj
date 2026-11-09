import { ArgsType, Field, Int } from '@nestjs/graphql';

@ArgsType()
export class CreateWalletTopupIntentArgs {
  @Field(() => Int)
  amount: number;
}
