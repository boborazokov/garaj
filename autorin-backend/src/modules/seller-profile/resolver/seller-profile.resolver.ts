import { Args, Context, Query, Resolver } from '@nestjs/graphql';
import { UseOptionalAuth } from 'src/auth/useAuth';
import { ContextType } from 'src/auth/interfaces';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { SellerStoreProfile } from '../types';
import { SellerProfileService } from '../service/seller-profile.service';

@Resolver()
export class SellerProfileResolver {
  constructor(private readonly profileService: SellerProfileService) {}

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
}
