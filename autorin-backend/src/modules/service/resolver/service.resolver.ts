import {
  Args,
  Context,
  Mutation,
  Parent,
  Query,
  ResolveField,
  Resolver,
} from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import { FavoriteService } from 'src/modules/favorite/service';
import { Types } from 'mongoose';
import { Part } from 'src/modules/part/schema';
import { Order } from 'src/modules/order/schema';
import { NearbyArgs } from 'src/shared/geo';
import { fromGeoJsonPoint, GeoPoint } from 'src/shared/geo/geo-point.object';
import { AutoService } from '../schema/service.schema';
import {
  CreateServiceArgs,
  GetServiceByIdArgs,
  GetServicesArgs,
} from '../dto/args/service.args';
import { PromoteServiceArgs } from '../dto/args/promote-service.args';
import { PaginatedServices } from '../types/paginated-services.type';
import { ServiceListingService } from '../service/service.service';
import { MapDiscoveryService } from '../service/discovery.service';
import { ServiceBookingService } from 'src/modules/service-booking/service/service-booking.service';
import { ServiceReviewService } from 'src/modules/service-review/service/service-review.service';
import { BookServiceInput } from 'src/modules/service-booking/dto/book-service.input';
import { AddReviewInput } from 'src/modules/service-review/dto/add-review.input';
import { ServiceBooking } from 'src/modules/service-booking/schema/service-booking.schema';
import { ServiceReview } from 'src/modules/service-review/schema/service-review.schema';

@Resolver(() => AutoService)
export class ServiceListingResolver {
  constructor(
    private readonly serviceService: ServiceListingService,
    private readonly discoveryService: MapDiscoveryService,
    private readonly bookingService: ServiceBookingService,
    private readonly reviewService: ServiceReviewService,
    private readonly favorites: FavoriteService,
  ) {}

  @ResolveField(() => GeoPoint)
  geoLocation(@Parent() service: AutoService & { geo?: { coordinates: number[] } }) {
    return fromGeoJsonPoint(service.geo) ?? { latitude: 0, longitude: 0 };
  }

  @UseOptionalAuth()
  @Query(() => [AutoService], { name: 'nearbyServices' })
  nearbyServices(@Args() args: NearbyArgs) {
    return this.serviceService.nearbyServices(args);
  }

  @UseOptionalAuth()
  @Query(() => [AutoService], { name: 'nearbyEmergencyServices' })
  nearbyEmergencyServices(@Args() args: NearbyArgs) {
    return this.serviceService.nearbyServices(args, { isEmergency: true });
  }

  @UseOptionalAuth()
  @Query(() => AutoService, { name: 'serviceDetails' })
  serviceDetails(@Args() args: GetServiceByIdArgs) {
    return this.serviceService.getServiceById(args);
  }

  @UseOptionalAuth()
  @Query(() => PaginatedServices, { name: 'getServices' })
  getServices(@Args() args: GetServicesArgs) {
    return this.serviceService.getServices(args);
  }

  @UseOptionalAuth()
  @Query(() => [AutoService], { name: 'topRatedServices' })
  topRatedServices() {
    return this.serviceService.topRatedServices();
  }

  @UseOptionalAuth()
  @Query(() => [Part], { name: 'nearbyProducts' })
  nearbyProducts(@Args() args: NearbyArgs) {
    return this.discoveryService.nearbyProducts(args);
  }

  @UseOptionalAuth()
  @Query(() => [Order], { name: 'nearbyOrders' })
  nearbyOrders(@Args() args: NearbyArgs) {
    return this.discoveryService.nearbyOrders(args);
  }

  @UseAuth()
  @Mutation(() => AutoService, { name: 'createService' })
  createService(@Args() args: CreateServiceArgs, @Context() ctx: ContextType) {
    return this.serviceService.createService(args, ctx);
  }

  @UseAuth()
  @Mutation(() => AutoService, { name: 'promoteService' })
  promoteService(@Args() args: PromoteServiceArgs, @Context() ctx: ContextType) {
    return this.serviceService.promoteService(args, ctx);
  }

  @UseAuth()
  @Mutation(() => ServiceBooking, { name: 'bookService' })
  bookService(@Args('data') data: BookServiceInput, @Context() ctx: ContextType) {
    return this.bookingService.bookService(data, ctx);
  }

  @UseAuth()
  @Mutation(() => ServiceReview, { name: 'addReview' })
  addReview(@Args('data') data: AddReviewInput, @Context() ctx: ContextType) {
    return this.reviewService.addReview(data, ctx);
  }

  @UseAuth()
  @Mutation(() => Boolean, { name: 'favoriteService' })
  async favoriteService(
    @Args('serviceId') serviceId: string,
    @Context() ctx: ContextType,
  ) {
    await this.favorites.addToFavorites(
      { favorite: { serviceId: new Types.ObjectId(serviceId) } },
      ctx,
    );
    return true;
  }

  @UseOptionalAuth()
  @Query(() => [ServiceReview], { name: 'serviceReviews' })
  serviceReviews(@Args('serviceId') serviceId: string) {
    return this.reviewService.listForService(serviceId);
  }
}

@Resolver(() => Part)
export class PartGeoResolver {
  @ResolveField(() => GeoPoint, { nullable: true })
  geoLocation(@Parent() part: Part & { geo?: { coordinates: number[] } }) {
    return fromGeoJsonPoint(part.geo);
  }
}

@Resolver(() => Order)
export class OrderGeoResolver {
  @ResolveField(() => GeoPoint, { nullable: true })
  geoLocation(@Parent() order: Order & { geo?: { coordinates: number[] } }) {
    return fromGeoJsonPoint(order.geo);
  }
}
