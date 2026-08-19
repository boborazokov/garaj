import { ModelDefinition } from '@nestjs/mongoose';
import { SchemaFactory } from '@nestjs/mongoose';
import * as mongoosePaginate from 'mongoose-paginate-v2';
import { COLLECTIONS } from 'src/constants';
import { AutoService } from '../schema/service.schema';

const schema = SchemaFactory.createForClass(AutoService);
schema.plugin(mongoosePaginate);
schema.index({ geo: '2dsphere' });

export const ServiceModel: ModelDefinition = {
  name: COLLECTIONS.SERVICES,
  schema,
};
