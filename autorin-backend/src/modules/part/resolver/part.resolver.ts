import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { PartService } from '../service';
import { ContextType } from 'src/auth/interfaces';
import { Public } from 'src/auth/decorators/public.decorator';
import {
  CreatePartArgs,
  GetPartByIdArgs,
  GetPartsArgs,
  PromotePartArgs,
  UpdatePartByIdArgs,
} from '../dto';
import { Part } from '../schema';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import { UseRole } from 'src/auth/useAuth/use-role.decorator';
import { UserRoleEnum } from 'src/modules/user/enums';
import { PaginatedParts } from '../types';

@Resolver()
export class PartResolver {
  constructor(private partService: PartService) {}

  @UseAuth()
  @Mutation(() => Part)
  createPart(@Args() args: CreatePartArgs, @Context() context: ContextType) {
    return this.partService.createPart(args, context);
  }

  @UseAuth()
  @Mutation(() => Part)
  updatePartById(
    @Args() args: UpdatePartByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.partService.updatePartById(args, context);
  }

  @UseAuth()
  @Mutation(() => Part)
  deletePartById(
    @Args() args: GetPartByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.partService.deletePartById(args, context);
  }

  @UseOptionalAuth()
  @Query(() => Part)
  getPartById(@Args() args: GetPartByIdArgs, @Context() context: ContextType) {
    return this.partService.getPartById(args, context);
  }

  @UseOptionalAuth()
  @Query(() => PaginatedParts)
  getParts(@Args() args: GetPartsArgs, @Context() context: ContextType) {
    return this.partService.getParts(args, context);
  }

  @UseAuth()
  @Mutation(() => Part)
  restorePartById(
    @Args() args: GetPartByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.partService.restorePartById(args, context);
  }

  /**
   * Admin fallback only. Users must go through `purchasePromotion`
   * (pay → auto top). Use this when payment succeeded but promote failed.
   */
  @UseRole(UserRoleEnum.ADMIN)
  @Mutation(() => Part)
  promotePartById(
    @Args() args: PromotePartArgs,
    @Context() context: ContextType,
  ) {
    return this.partService.promotePartById(args, context);
  }

  @Public()
  @Mutation(() => Part)
  recordPartPhoneClick(@Args() args: GetPartByIdArgs) {
    return this.partService.recordPartPhoneClick(args);
  }

  @Public()
  @Mutation(() => Part)
  recordPartShare(@Args() args: GetPartByIdArgs) {
    return this.partService.recordPartShare(args);
  }
}
