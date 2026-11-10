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

  /**
   * Admin overrides for banner tariffs.
   * Key: `${placement}:${plan}` (e.g. BRAND:DAY) → amount UZS.
   */
  @Prop({ type: Object, default: {} })
  advertisementTariffs?: Record<string, number>;

  /**
   * Admin overrides for listing boost tariffs.
   * Key: plan enum (BASIC, STANDARD, …) → amount UZS.
   */
  @Prop({ type: Object, default: {} })
  promotionTariffs?: Record<string, number>;

  /** Optional day-count overrides per promotion plan. */
  @Prop({ type: Object, default: {} })
  promotionTariffDays?: Record<string, number>;

  /** Optional discount percent (0–100) shown with each plan. */
  @Prop({ type: Object, default: {} })
  promotionTariffDiscounts?: Record<string, number>;

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
