import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { AppSettings } from 'src/modules/app-settings/schema';
import { Part } from 'src/modules/part/schema';
import { PaginatedParts } from 'src/modules/part/types';
import { User } from 'src/modules/user/schema';
import { UserRoleEnum } from 'src/modules/user/enums';
import { PaginatedUsers } from 'src/modules/user/types';
import { PaginatedOrders } from 'src/modules/order/types/paginated-orders.type';
import {
  AdminDailyReportArgs,
  AdminListOrdersArgs,
  AdminListPartsArgs,
  AdminListUsersArgs,
  ModeratePartArgs,
  SetContactInfoArgs,
  SetProductModerationArgs,
  SetUserRoleArgs,
  AdminSetUserImageArgs,
  AdminSetUserVerifiedArgs,
} from '../dto/args/admin.args';
import { AdminDailyReport } from 'src/modules/analytics/types/admin-daily-report.type';
import { AdminStats } from '../types/admin-stats.type';
import { AdminService } from '../service/admin.service';

@Resolver()
export class AdminResolver {
  constructor(private adminService: AdminService) {}

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => AppSettings)
  getAppSettings(@Context() context: ContextType) {
    return this.adminService.getAppSettings(context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => AppSettings)
  setProductModerationEnabled(
    @Args() args: SetProductModerationArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.setProductModerationEnabled(args.enabled, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => AppSettings)
  setContactInfo(
    @Args() args: SetContactInfoArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.setContactInfo(
      args.supportEmail,
      args.supportPhone,
      context,
    );
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => AdminStats)
  getAdminStats(@Context() context: ContextType) {
    return this.adminService.getAdminStats(context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => AdminDailyReport)
  getAdminDailyReport(
    @Args() args: AdminDailyReportArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.getAdminDailyReport(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => PaginatedUsers)
  adminListUsers(
    @Args() args: AdminListUsersArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.listUsers(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => User)
  adminSetUserRole(
    @Args() args: SetUserRoleArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.setUserRole(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => User)
  adminSetUserImage(
    @Args() args: AdminSetUserImageArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.setUserImage(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => User)
  adminSetUserVerified(
    @Args() args: AdminSetUserVerifiedArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.setUserVerified(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN, UserRoleEnum.MODERATOR)
  @Query(() => PaginatedParts)
  getPendingParts(
    @Args() args: AdminListPartsArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.getPendingParts(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => PaginatedOrders)
  adminListOrders(
    @Args() args: AdminListOrdersArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.listOrders(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN)
  @Query(() => PaginatedParts)
  adminListParts(
    @Args() args: AdminListPartsArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.listAllParts(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN, UserRoleEnum.MODERATOR)
  @Mutation(() => Part)
  approvePart(
    @Args() args: ModeratePartArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.approvePart(args, context);
  }

  @UseRole(UserRoleEnum.ADMIN, UserRoleEnum.MODERATOR)
  @Mutation(() => Part)
  rejectPart(
    @Args() args: ModeratePartArgs,
    @Context() context: ContextType,
  ) {
    return this.adminService.rejectPart(args, context);
  }
}
