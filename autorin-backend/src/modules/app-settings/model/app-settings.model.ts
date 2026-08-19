import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { AppSettings } from '../schema';

export const AppSettingsModel: ModelDefinition = {
  name: COLLECTIONS.APP_SETTINGS,
  schema: SchemaFactory.createForClass(AppSettings),
};
