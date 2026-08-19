import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { PartService } from '../service';
import { ContextType } from 'src/auth/interfaces';
import {
  CreatePartArgs,
  GetPartByIdArgs,
  GetPartsArgs,
  PromotePartArgs,
  UpdatePartByIdArgs,
} from '../dto';
import { Part } from '../schema';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
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
   * Promotes the part for `days` days. Cost / billing is out-of-scope here;
   * front-ends should hide the action behind a paywall when needed.
   */
  @UseAuth()
  @Mutation(() => Part)
  promotePartById(
    @Args() args: PromotePartArgs,
    @Context() context: ContextType,
  ) {
    return this.partService.promotePartById(args, context);
  }
}
