import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { UserRoleEnum } from '../enums';
import { SellerPrivacy, SellerSocialLinks } from './seller-profile-embedded.schema';

@ObjectType()
@Schema({ timestamps: true })
export class User {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  @Prop()
  name: string;

  @Prop()
  tgId: number;

  @Field()
  @Prop({ unique: true, required: true })
  phone: string;

  @Field()
  @Prop()
  password: string;

  @Field(() => UserRoleEnum)
  @Prop({ enum: Object.values(UserRoleEnum), default: UserRoleEnum.USER })
  role: UserRoleEnum;

  @Field({ nullable: true })
  @Prop()
  address: string;

  /** Profile / seller avatar URL (MinIO: users/avatars). */
  @Field({ nullable: true })
  @Prop()
  image?: string;

  /** Optional store banner (MinIO: users/banners). */
  @Field({ nullable: true })
  @Prop()
  banner?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, sparse: true, unique: true, index: true })
  username?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, maxlength: 280, default: '' })
  bio?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, maxlength: 2000, default: '' })
  description?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  email?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  country?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  region?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  city?: string;

  @Field(() => SellerSocialLinks, { nullable: true })
  @Prop({ type: SellerSocialLinks, default: () => ({}) })
  socialLinks?: SellerSocialLinks;

  @Field(() => SellerPrivacy, { nullable: true })
  @Prop({
    type: SellerPrivacy,
    default: () => ({
      showPhone: false,
      showEmail: false,
      showLocation: true,
      showFollowers: true,
      allowMessages: true,
    }),
  })
  privacy?: SellerPrivacy;

  @Field({ nullable: true })
  @Prop({ default: false })
  verified?: boolean;

  @Prop({ default: 0 })
  profileViews?: number;

  /** Set when the user deletes their account (Apple App Store requirement). */
  @Prop({ type: Date, default: null, index: true })
  deletedAt?: Date | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
