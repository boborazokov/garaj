import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import * as mongoosePaginate from 'mongoose-paginate-v2';
import { COLLECTIONS } from 'src/constants';
import { Order } from '../schema';

const orderSchema = SchemaFactory.createForClass(Order);
orderSchema.plugin(mongoosePaginate);
orderSchema.index({ geo: '2dsphere' });

export const OrderModel: ModelDefinition = {
  name: COLLECTIONS.ORDERS,
  schema: orderSchema,
};
