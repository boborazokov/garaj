import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import * as mongoosePaginate from 'mongoose-paginate-v2';
import { PromotionPayment } from '../schema';

const schema = SchemaFactory.createForClass(PromotionPayment);
schema.plugin(mongoosePaginate);
schema.index({ user: 1, createdAt: -1 });
schema.index({ targetType: 1, targetId: 1, createdAt: -1 });

export const PromotionPaymentModel: ModelDefinition = {
  name: COLLECTIONS.PROMOTION_PAYMENTS,
  schema,
};
