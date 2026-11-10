import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth } from 'src/auth/useAuth';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { Public } from 'src/auth/decorators';
import { UserRoleEnum } from 'src/modules/user/enums';
import {
  AdminFulfillPromotionArgs,
  AdminRetryPromotionPaymentArgs,
  CancelPromotionArgs,
  PurchasePromotionArgs,
} from '../dto';
import { PromotionPayment, PromotionPlanPrice } from '../schema';
import { PromotionPaymentService } from '../service';

@Resolver(() => PromotionPayment)
export class PromotionPaymentResolver {
  constructor(private readonly promotionPaymentService: PromotionPaymentService) {}

  @Public()
  @Query(() => [PromotionPlanPrice], { name: 'promotionPlanPrices' })
  promotionPlanPrices() {
    return this.promotionPaymentService.getPlanPrices();
  }

  /**
   * User selects a top plan, pays, and the listing is boosted automatically.
   * Admin only steps in if payment/promote fails (see adminFulfillPromotion).
   * Buying again while active extends from the current end date.
   */
  @UseAuth()
  @Mutation(() => PromotionPayment, { name: 'purchasePromotion' })
  purchasePromotion(
    @Args() args: PurchasePromotionArgs,
    @Context() context: ContextType,
  ) {
    return this.promotionPaymentService.purchasePromotion(args, context);
  }

  /** Owner turns off boost early — no refund. */
  @UseAuth()
  @Mutation(() => Boolean, { name: 'cancelPromotion' })
  cancelPromotion(
    @Args() args: CancelPromotionArgs,
    @Context() context: ContextType,
  ) {
    return this.promotionPaymentService.cancelPromotion(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Boolean, { name: 'adminFulfillPromotion' })
  adminFulfillPromotion(
    @Args() args: AdminFulfillPromotionArgs,
    @Context() context: ContextType,
  ) {
    return this.promotionPaymentService.adminFulfillPromotion(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => PromotionPayment, { name: 'adminRetryPromotionPayment' })
  adminRetryPromotionPayment(
    @Args() args: AdminRetryPromotionPaymentArgs,
    @Context() context: ContextType,
  ) {
    return this.promotionPaymentService.adminRetryPromotionPayment(
      args,
      context,
    );
  }
}
