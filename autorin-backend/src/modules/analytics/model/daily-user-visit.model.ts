import { ModelDefinition } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { DailyUserVisit, DailyUserVisitSchema } from '../schema/daily-user-visit.schema';

export const DailyUserVisitModel: ModelDefinition = {
  name: COLLECTIONS.DAILY_USER_VISITS,
  schema: DailyUserVisitSchema,
};
