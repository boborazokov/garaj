import { SchemaFactory } from '@nestjs/mongoose';
import { SellerFollow } from '../schema/seller-follow.schema';

export const SellerFollowSchema = SchemaFactory.createForClass(SellerFollow);

SellerFollowSchema.index({ followerId: 1, sellerId: 1 }, { unique: true });
SellerFollowSchema.index({ sellerId: 1, createdAt: -1 });

export const SellerFollowModel = {
  name: 'SellerFollow',
  schema: SellerFollowSchema,
  collection: 'seller_follows',
};
