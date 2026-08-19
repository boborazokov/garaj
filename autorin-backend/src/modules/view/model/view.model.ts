import { ModelDefinition } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { ViewSchema } from '../schema';

export const ViewModel: ModelDefinition = {
  name: COLLECTIONS.VIEWS,
  schema: ViewSchema,
};
