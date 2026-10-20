import { Field, InputType, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';

@ObjectType()
@InputType('SellerSocialLinksInput')
@Schema({ _id: false })
export class SellerSocialLinks {
  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  telegram?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  instagram?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  website?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  youtube?: string;

  @Field({ nullable: true })
  @Prop({ trim: true, default: '' })
  facebook?: string;
}

@ObjectType()
@InputType('SellerPrivacyInput')
@Schema({ _id: false })
export class SellerPrivacy {
  @Field({ defaultValue: false })
  @Prop({ default: false })
  showPhone?: boolean;

  @Field({ defaultValue: false })
  @Prop({ default: false })
  showEmail?: boolean;

  @Field({ defaultValue: true })
  @Prop({ default: true })
  showLocation?: boolean;

  @Field({ defaultValue: true })
  @Prop({ default: true })
  allowMessages?: boolean;
}
