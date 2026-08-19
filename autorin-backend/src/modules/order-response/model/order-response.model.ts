import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { OrderResponse } from '../schema/order-response.schema';

export const orderResponseSchema = SchemaFactory.createForClass(OrderResponse);
orderResponseSchema.index({ order: 1, createdAt: -1 });

export const OrderResponseModel: ModelDefinition = {
  name: COLLECTIONS.ORDER_RESPONSES,
  schema: orderResponseSchema,
};
