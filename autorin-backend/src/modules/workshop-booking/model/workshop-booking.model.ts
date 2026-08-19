import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { WorkshopBooking } from '../schema/workshop-booking.schema';

export const WorkshopBookingModel: ModelDefinition = {
  name: COLLECTIONS.WORKSHOP_BOOKINGS,
  schema: SchemaFactory.createForClass(WorkshopBooking),
};
