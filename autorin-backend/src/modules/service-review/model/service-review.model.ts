import { ModelDefinition } from '@nestjs/mongoose';
import { SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { ServiceReview } from '../schema/service-review.schema';

const schema = SchemaFactory.createForClass(ServiceReview);
schema.index({ service: 1, user: 1 }, { unique: true });

export const ServiceReviewModel: ModelDefinition = {
  name: COLLECTIONS.SERVICE_REVIEWS,
  schema,
};
