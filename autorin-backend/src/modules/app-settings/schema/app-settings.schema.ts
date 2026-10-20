import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';

export const APP_SETTINGS_ID = 'global';

@ObjectType()
@Schema({ collection: COLLECTIONS.APP_SETTINGS, timestamps: true })
export class AppSettings {
  @Field()
  @Prop({ type: String, default: APP_SETTINGS_ID })
  _id: string;

  @Field()
  /** Fresh installs review listings before they go public. */
  @Prop({ default: true })
  productModerationEnabled: boolean;

  @Field({ nullable: true })
  @Prop({ default: '' })
  supportEmail?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  supportPhone?: string;

  @Field()
  updatedAt?: Date;
}

@ObjectType()
export class ContactInfo {
  @Field()
  supportEmail: string;

  @Field()
  supportPhone: string;
}
