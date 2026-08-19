import { ModelDefinition } from '@nestjs/mongoose';
import { SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { ServiceBooking } from '../schema/service-booking.schema';

const schema = SchemaFactory.createForClass(ServiceBooking);
schema.index({ service: 1, user: 1 });

export const ServiceBookingModel: ModelDefinition = {
  name: COLLECTIONS.SERVICE_BOOKINGS,
  schema,
};
