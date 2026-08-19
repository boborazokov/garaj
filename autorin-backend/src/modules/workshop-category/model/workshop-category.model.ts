import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { WorkshopCategory } from '../schema/workshop-category.schema';

export const WorkshopCategoryModel: ModelDefinition = {
  name: COLLECTIONS.WORKSHOP_CATEGORIES,
  schema: SchemaFactory.createForClass(WorkshopCategory),
};
