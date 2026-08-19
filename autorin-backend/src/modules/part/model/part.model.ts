import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { Part } from '../schema';
import { COLLECTIONS } from 'src/constants';
import * as mongoosePaginate from 'mongoose-paginate-v2';

const partSchema = SchemaFactory.createForClass(Part);

partSchema.plugin(mongoosePaginate);
partSchema.index({ geo: '2dsphere' });

export const PartModel: ModelDefinition = {
  name: COLLECTIONS.PARTS,
  schema: partSchema,
};
