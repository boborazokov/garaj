import { Args, Mutation, Query, Resolver } from '@nestjs/graphql';
import { Public } from 'src/auth/decorators';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { UserRoleEnum } from 'src/modules/user/enums';
import { Advertisement } from '../schema';
import { AdvertisementService } from '../service';
import {
  AdminListAdvertisementsArgs,
  CreateAdvertisementArgs,
  DeleteAdvertisementArgs,
  GetAdvertisementsArgs,
  UpdateAdvertisementArgs,
} from '../dto/args';
import { PaginatedAdvertisements } from '../types/paginated-advertisements.type';

@Resolver(() => Advertisement)
export class AdvertisementResolver {
  constructor(private advertisementService: AdvertisementService) {}

  /**
   * Public banner feed consumed by the mobile app. Filtered by `type` so the
   * client can pick the surface (HOME / PART / WORKSHOP / etc.) without
   * downloading the entire pool. Kept unauthenticated so banners render even
   * for guests.
   */
  @Public()
  @Query(() => [Advertisement])
  getAdvertisements(@Args() args: GetAdvertisementsArgs) {
    return this.advertisementService.listPublic(args);
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
}
