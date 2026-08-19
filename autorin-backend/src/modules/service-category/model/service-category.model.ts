import { ModelDefinition } from '@nestjs/mongoose';
import { SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { ServiceCategory } from '../schema/service-category.schema';

const schema = SchemaFactory.createForClass(ServiceCategory);

export const ServiceCategoryModel: ModelDefinition = {
  name: COLLECTIONS.SERVICE_CATEGORIES,
  schema,
};
