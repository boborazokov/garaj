import { Args, Context, Mutation, Query, Resolver } from '@nestjs/graphql';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import { ContextType } from 'src/auth/interfaces';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { GetSellerFollowersArgs } from '../dto/args/get-seller-followers.args';
import { PaginatedSellerFollowers, SellerStoreProfile } from '../types';
import { SellerProfileService } from '../service/seller-profile.service';
import { SellerFollowService } from '../service/seller-follow.service';

@Resolver()
export class SellerProfileResolver {
  constructor(
    private readonly profileService: SellerProfileService,
    private readonly followService: SellerFollowService,
  ) {}

  @UseOptionalAuth()
  @Query(() => SellerStoreProfile, { name: 'getSellerProfile' })
  getSellerProfile(
    @Args('sellerId', { type: () => ObjectIdScalar }) sellerId: Types.ObjectId,
    @Context() ctx: ContextType,
  ) {
    return this.profileService.getSellerProfile(
      sellerId.toString(),
      ctx.userId?.toString(),
    );
  }

  @UseAuth()
  @Mutation(() => Boolean, { name: 'followSeller' })
  followSeller(
    @Args('sellerId', { type: () => ObjectIdScalar }) sellerId: Types.ObjectId,
    @Context() ctx: ContextType,
  ) {
    return this.followService.follow(ctx.userId!.toString(), sellerId.toString());
  }

  @UseAuth()
  @Mutation(() => Boolean, { name: 'unfollowSeller' })
  unfollowSeller(
    @Args('sellerId', { type: () => ObjectIdScalar }) sellerId: Types.ObjectId,
    @Context() ctx: ContextType,
  ) {
    return this.followService.unfollow(ctx.userId!.toString(), sellerId.toString());
  }

  @UseAuth()
  @Query(() => PaginatedSellerFollowers, { name: 'getSellerFollowers' })
  getSellerFollowers(
    @Args() args: GetSellerFollowersArgs,
    @Context() ctx: ContextType,
  ) {
    return this.followService.listFollowersForOwner(
      args.sellerId.toString(),
      ctx.userId!.toString(),
      args.pagination,
    );
  }
}
