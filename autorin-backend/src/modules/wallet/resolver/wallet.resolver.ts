import {
  Args,
  Context,
  Int,
  Mutation,
  Parent,
  Query,
  ResolveField,
  Resolver,
} from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth } from 'src/auth/useAuth';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { UserRoleEnum } from 'src/modules/user/enums';
import {
  AdminCreditWalletArgs,
  AdminWalletArgs,
  AdminWalletTransactionsArgs,
  CreateWalletTopupIntentArgs,
  MyWalletTransactionsArgs,
} from '../dto';
import { Wallet, WalletTransaction } from '../schema';
import { WalletService } from '../service';

@Resolver(() => Wallet)
export class WalletResolver {
  constructor(private readonly walletService: WalletService) {}

  @ResolveField(() => Int, { name: 'availableTotal' })
  availableTotal(@Parent() wallet: Wallet) {
    return (wallet.mainBalance ?? 0) + (wallet.bonusBalance ?? 0);
  }

  @UseAuth()
  @Query(() => Wallet, { name: 'myWallet' })
  myWallet(@Context() context: ContextType) {
    return this.walletService.myWallet(context);
  }

  @UseAuth()
  @Query(() => [WalletTransaction], { name: 'myWalletTransactions' })
  myWalletTransactions(
    @Args() args: MyWalletTransactionsArgs,
    @Context() context: ContextType,
  ) {
    return this.walletService.myWalletTransactions(args, context);
  }

  @UseAuth()
  @Mutation(() => WalletTransaction, { name: 'createWalletTopupIntent' })
  createWalletTopupIntent(
    @Args() args: CreateWalletTopupIntentArgs,
    @Context() context: ContextType,
  ) {
    return this.walletService.createWalletTopupIntent(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => Wallet, { name: 'adminWallet' })
  adminWallet(
    @Args() args: AdminWalletArgs,
    @Context() context: ContextType,
  ) {
    return this.walletService.adminWallet(args.userId, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => [WalletTransaction], { name: 'adminWalletTransactions' })
  adminWalletTransactions(
    @Args() args: AdminWalletTransactionsArgs,
    @Context() context: ContextType,
  ) {
    return this.walletService.adminWalletTransactions(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => WalletTransaction, { name: 'adminCreditWallet' })
  adminCreditWallet(
    @Args() args: AdminCreditWalletArgs,
    @Context() context: ContextType,
  ) {
    return this.walletService.adminCreditWallet(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => [WalletTransaction], { name: 'adminListWithdrawRequests' })
  adminListWithdrawRequests(@Context() context: ContextType) {
    return this.walletService.adminListWithdrawRequests(context);
  }
}
