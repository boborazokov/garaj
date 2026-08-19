import { SchemaFactory } from '@nestjs/mongoose';
import { SellerProfileView } from '../schema/seller-profile-view.schema';

export const SellerProfileViewSchema =
  SchemaFactory.createForClass(SellerProfileView);

SellerProfileViewSchema.index({ viewerId: 1, sellerId: 1 }, { unique: true });
SellerProfileViewSchema.index({ sellerId: 1, createdAt: -1 });

export const SellerProfileViewModel = {
  name: 'SellerProfileView',
  schema: SellerProfileViewSchema,
  collection: 'seller_profile_views',
};
