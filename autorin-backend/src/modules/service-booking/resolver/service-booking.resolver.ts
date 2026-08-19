import { Context, Query, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth } from 'src/auth/useAuth';
import { ServiceBooking } from '../schema/service-booking.schema';
import { ServiceBookingService } from '../service/service-booking.service';

@Resolver(() => ServiceBooking)
export class ServiceBookingResolver {
  constructor(private readonly bookingService: ServiceBookingService) {}

  @UseAuth()
  @Query(() => [ServiceBooking], { name: 'myServiceBookings' })
  myServiceBookings(@Context() ctx: ContextType) {
    return this.bookingService.myBookings(ctx);
  }
}
