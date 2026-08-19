import { Field, ObjectType } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { SellerSocialLinks } from 'src/modules/user/schema/seller-profile-embedded.schema';

@ObjectType()
export class SellerCategoryStat {
  @Field(() => ObjectIdScalar)
  categoryId: Types.ObjectId;

  @Field()
  name: string;

  @Field({ nullable: true })
  slug?: string;

  @Field()
  productCount: number;
}

@ObjectType()
export class SellerStoreStats {
  @Field()
  totalProducts: number;

  @Field()
  activeProducts: number;

  @Field()
  categoriesCount: number;

  @Field()
  followersCount: number;

  @Field()
  profileViews: number;
}

@ObjectType()
export class SellerStoreProfile {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  name: string;

  @Field({ nullable: true })
  username?: string;

  @Field({ nullable: true })
  image?: string;

  @Field({ nullable: true })
  banner?: string;

  @Field({ nullable: true })
  bio?: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  email?: string;

  @Field({ nullable: true })
  country?: string;

  @Field({ nullable: true })
  region?: string;

  @Field({ nullable: true })
  city?: string;

  @Field({ nullable: true })
  address?: string;

  @Field(() => SellerSocialLinks, { nullable: true })
  socialLinks?: SellerSocialLinks;

  @Field()
  verified: boolean;

  @Field()
  createdAt: Date;

  @Field(() => SellerStoreStats)
  stats: SellerStoreStats;

  @Field(() => [SellerCategoryStat])
  categories: SellerCategoryStat[];

  @Field()
  isFollowing: boolean;

  @Field()
  isOwnProfile: boolean;

  @Field()
  allowMessages: boolean;
}
