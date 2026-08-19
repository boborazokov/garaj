import { Field, InputType } from '@nestjs/graphql';

import {

  SellerPrivacy,

  SellerSocialLinks,

} from '../../schema/seller-profile-embedded.schema';



@InputType()

export class UserUpdateInput {

  @Field({ nullable: true })

  name?: string;



  @Field({ nullable: true })

  address?: string;



  @Field({ nullable: true })

  username?: string;



  @Field({ nullable: true })

  banner?: string;



  @Field({ nullable: true })

  bio?: string;



  @Field({ nullable: true })

  description?: string;



  @Field({ nullable: true })

  email?: string;



  @Field({ nullable: true })

  country?: string;



  @Field({ nullable: true })

  region?: string;



  @Field({ nullable: true })

  city?: string;



  @Field(() => SellerSocialLinks, { nullable: true })

  socialLinks?: SellerSocialLinks;



  @Field(() => SellerPrivacy, { nullable: true })

  privacy?: SellerPrivacy;

}


