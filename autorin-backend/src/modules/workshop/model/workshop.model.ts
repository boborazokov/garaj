import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { Workshop } from '../schema';
import { COLLECTIONS } from 'src/constants';
import * as mongoosePaginate from 'mongoose-paginate-v2';

const workshopSchema = SchemaFactory.createForClass(Workshop);

workshopSchema.plugin(mongoosePaginate);
workshopSchema.index({ geo: '2dsphere' });
workshopSchema.index({ mapLocation: '2dsphere' });

export const WorkshopModel: ModelDefinition = {
  name: COLLECTIONS.WORKSHOPS,
  schema: workshopSchema,
};
