import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { WorkshopReview } from '../schema/workshop-review.schema';

const schema = SchemaFactory.createForClass(WorkshopReview);
schema.index({ workshop: 1, user: 1 }, { unique: true });

export const WorkshopReviewModel: ModelDefinition = {
  name: COLLECTIONS.WORKSHOP_REVIEWS,
  schema,
};
