import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { Advertisement } from '../schema';
import { COLLECTIONS } from 'src/constants';
import * as mongoosePaginate from 'mongoose-paginate-v2';

const advertisementSchema = SchemaFactory.createForClass(Advertisement);

advertisementSchema.plugin(mongoosePaginate);

export const AdvertisementModel: ModelDefinition = {
  name: COLLECTIONS.ADVERTISEMENTS,
  schema: advertisementSchema,
};
