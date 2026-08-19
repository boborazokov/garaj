import { Args, Context, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth } from 'src/auth/useAuth';
import { WorkshopBooking } from '../schema/workshop-booking.schema';
import { WorkshopBookingService } from '../service/workshop-booking.service';

@Resolver(() => WorkshopBooking)
export class WorkshopBookingResolver {
  constructor(private readonly bookingService: WorkshopBookingService) {}

  @UseAuth()
  @Query(() => [WorkshopBooking], { name: 'myWorkshopBookings' })
  myWorkshopBookings(@Context() ctx: ContextType) {
    return this.bookingService.myBookings(ctx);
  }
}
