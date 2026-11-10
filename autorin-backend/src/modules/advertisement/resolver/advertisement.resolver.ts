import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { Public } from 'src/auth/decorators';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth } from 'src/auth/useAuth';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { UserRoleEnum } from 'src/modules/user/enums';
import {
  Advertisement,
  AdvertisementPlanPrice,
  AdvertisementSlotInfo,
} from '../schema';
import { AdvertisementService } from '../service';
import {
  AdminListAdvertisementsArgs,
  AdvertisementIdArgs,
  AdvertisementSlotInfoArgs,
  CreateAdvertisementArgs,
  DeleteAdvertisementArgs,
  GetAdvertisementsArgs,
  PurchaseAdvertisementArgs,
  RecordAdvertisementArgs,
  UpdateAdvertisementArgs,
} from '../dto/args';
import { PaginatedAdvertisements } from '../types/paginated-advertisements.type';

@Resolver(() => Advertisement)
export class AdvertisementResolver {
  constructor(private advertisementService: AdvertisementService) {}

  @Public()
  @Query(() => [Advertisement])
  getAdvertisements(@Args() args: GetAdvertisementsArgs) {
    return this.advertisementService.listPublic(args);
  }

  @Public()
  @Query(() => [AdvertisementPlanPrice], { name: 'advertisementPlanPrices' })
  advertisementPlanPrices() {
    return this.advertisementService.getPlanPrices();
  }

  @Public()
  @Query(() => AdvertisementSlotInfo, { name: 'advertisementSlotInfo' })
  advertisementSlotInfo(@Args() args: AdvertisementSlotInfoArgs) {
    return this.advertisementService.slotInfo(args.type);
  }

  @UseAuth()
  @Query(() => [Advertisement], { name: 'myAdvertisements' })
  myAdvertisements(@Context() context: ContextType) {
    return this.advertisementService.listMine(context);
  }

  @UseAuth()
  @Mutation(() => Advertisement, { name: 'purchaseAdvertisement' })
  purchaseAdvertisement(
    @Args() args: PurchaseAdvertisementArgs,
    @Context() context: ContextType,
  ) {
    return this.advertisementService.purchase(args, context);
  }

  @UseAuth()
  @Mutation(() => Advertisement, { name: 'pauseMyAdvertisement' })
  pauseMyAdvertisement(
    @Args() args: AdvertisementIdArgs,
    @Context() context: ContextType,
  ) {
    return this.advertisementService.pauseMine(args.advertisementId, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => PaginatedAdvertisements)
  adminListAdvertisements(@Args() args: AdminListAdvertisementsArgs) {
    return this.advertisementService.list(args);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Advertisement)
  createAdvertisement(@Args() args: CreateAdvertisementArgs) {
    return this.advertisementService.create(args.data);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Advertisement)
  updateAdvertisement(@Args() args: UpdateAdvertisementArgs) {
    return this.advertisementService.update(args.advertisementId, args.data);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Boolean)
  deleteAdvertisement(@Args() args: DeleteAdvertisementArgs) {
    return this.advertisementService.delete(args.advertisementId);
  }

  @Public()
  @Mutation(() => Advertisement)
  recordAdvertisementImpression(@Args() args: RecordAdvertisementArgs) {
    return this.advertisementService.recordImpression(args.advertisementId);
  }

  @Public()
  @Mutation(() => Advertisement)
  recordAdvertisementClick(@Args() args: RecordAdvertisementArgs) {
    return this.advertisementService.recordClick(args.advertisementId);
  }
}
