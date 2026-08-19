import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { Category } from '../schema';
import { COLLECTIONS } from 'src/constants';
import * as mongoosePaginate from 'mongoose-paginate-v2';

const categorySchema = SchemaFactory.createForClass(Category);

categorySchema.plugin(mongoosePaginate);

export const CategoryModel: ModelDefinition = {
  name: COLLECTIONS.CATEGORIES,
  schema: categorySchema,
};
