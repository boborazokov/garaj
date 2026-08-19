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
  @Prop({ default: false })
  productModerationEnabled: boolean;

  @Field()
  updatedAt?: Date;
}
