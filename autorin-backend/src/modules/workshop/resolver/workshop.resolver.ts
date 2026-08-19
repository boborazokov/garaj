import {
  Args,
  Context,
  Mutation,
  Parent,
  Query,
  ResolveField,
  Resolver,
} from '@nestjs/graphql';
import { WorkshopService } from '../service';
import { ContextType } from 'src/auth/interfaces';
import {
  CreateWorkshopArgs,
  GetWorkshopByIdArgs,
  GetWorkshopsArgs,
  PromoteWorkshopArgs,
  UpdateWorkshopByIdArgs,
} from '../dto';
import { Workshop, resolveWorkshopGeo } from '../schema';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import { PaginatedWorkshops } from '../types';
import { WorkshopDiscoveryService } from '../service/workshop-discovery.service';
import { NearbyArgs } from 'src/shared/geo';
import { GeoPoint } from 'src/shared/geo/geo-point.object';
import { WorkshopCategory } from 'src/modules/workshop-category/schema/workshop-category.schema';
import { WorkshopReviewService } from 'src/modules/workshop-review/service/workshop-review.service';
import { WorkshopBookingService } from 'src/modules/workshop-booking/service/workshop-booking.service';
import { GetWorkshopReviewsArgs } from 'src/modules/workshop-review/dto/args/get-workshop-reviews.args';
import { AddWorkshopReviewInput } from 'src/modules/workshop-review/dto/add-workshop-review.input';
import { ReplyWorkshopReviewInput } from 'src/modules/workshop-review/dto/reply-workshop-review.input';
import { UpdateWorkshopReviewInput } from 'src/modules/workshop-review/dto/update-workshop-review.input';
import { PaginatedWorkshopReviews } from 'src/modules/workshop-review/types/paginated-workshop-reviews.type';
import { BookWorkshopInput } from 'src/modules/workshop-booking/dto/book-workshop.input';
import { WorkshopReview } from 'src/modules/workshop-review/schema/workshop-review.schema';
import { WorkshopBooking } from 'src/modules/workshop-booking/schema/workshop-booking.schema';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';
import { WorkshopGeospatialService } from '../service/workshop-geospatial.service';
import {
  NearbyLatLngArgs,
  WorkshopMapDiscoveryArgs,
} from '../dto/inputs/workshop-map-discovery.input';
import { MapSearchResult } from '../types/map-search-result.type';
import { Part } from 'src/modules/part/schema';

@Resolver(() => Workshop)
export class WorkshopResolver {
  constructor(
    private workshopService: WorkshopService,
    private discoveryService: WorkshopDiscoveryService,
    private geospatialService: WorkshopGeospatialService,
    private reviewService: WorkshopReviewService,
    private bookingService: WorkshopBookingService,
  ) {}

  @ResolveField(() => GeoPoint)
  geoLocation(@Parent() workshop: Workshop & { geo?: { coordinates: number[] } }) {
    return resolveWorkshopGeo(workshop) ?? { latitude: 0, longitude: 0 };
  }

  @ResolveField(() => [WorkshopCategory])
  categories(@Parent() workshop: Workshop & { categoryIds?: WorkshopCategory[] }) {
    return (workshop as Workshop & { categories?: WorkshopCategory[] }).categories
      ?? workshop.categoryIds
      ?? [];
  }

  @ResolveField(() => Boolean)
  verified(@Parent() workshop: Workshop) {
    return workshop.verified ?? false;
  }

  @ResolveField(() => Number)
  rating(@Parent() workshop: Workshop) {
    return workshop.rating ?? 0;
  }

  @ResolveField(() => Number)
  reviewCount(@Parent() workshop: Workshop) {
    return workshop.reviewCount ?? 0;
  }

  @ResolveField(() => Boolean)
  fastResponse(@Parent() workshop: Workshop) {
    return workshop.fastResponse ?? false;
  }

  @ResolveField(() => Boolean)
  isOpenNow(@Parent() workshop: Workshop) {
    return workshop.isOpenNow ?? false;
  }

  @ResolveField(() => [String])
  gallery(@Parent() workshop: Workshop & { images?: string[] }) {
    if (workshop.gallery?.length) return workshop.gallery;
    return workshop.images ?? [];
  }

  @ResolveField(() => Number)
  bookingCount(@Parent() workshop: Workshop) {
    return workshop.bookingCount ?? 0;
  }

  @ResolveField(() => Number)
  viewCount(@Parent() workshop: Workshop) {
    return workshop.viewCount ?? 0;
  }

  @UseAuth()
  @Mutation(() => Workshop)
  createWorkshop(
    @Args() args: CreateWorkshopArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.createWorkshop(args, context);
  }

  @UseAuth()
  @Mutation(() => Workshop)
  updateWorkshopById(
    @Args() args: UpdateWorkshopByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.updateWorkshopById(args, context);
  }

  @UseAuth()
  @Mutation(() => Workshop)
  deleteWorkshopById(
    @Args() args: GetWorkshopByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.deleteWorkshopById(args, context);
  }

  @UseOptionalAuth()
  @Query(() => Workshop, { name: 'getWorkshopById' })
  getWorkshopById(
    @Args() args: GetWorkshopByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.getWorkshopById(args, context);
  }

  @UseOptionalAuth()
  @Query(() => Workshop, { name: 'workshopDetails' })
  workshopDetails(
    @Args() args: GetWorkshopByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.getWorkshopById(args, context);
  }

  @UseOptionalAuth()
  @Query(() => PaginatedWorkshops)
  getWorkshops(
    @Args() args: GetWorkshopsArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.getWorkshops(args, context);
  }

  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'nearbyWorkshops' })
  nearbyWorkshops(@Args() args: NearbyArgs) {
    return this.discoveryService.nearbyWorkshops(args);
  }

  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'recommendedWorkshops' })
  recommendedWorkshops() {
    return this.discoveryService.recommendedWorkshops();
  }

  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'popularNearbyWorkshops' })
  popularNearbyWorkshops(@Args() args: NearbyArgs) {
    return this.discoveryService.popularNearby(args);
  }

  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'openNowWorkshops' })
  openNowWorkshops(@Args() args: NearbyArgs) {
    return this.discoveryService.openNowWorkshops(args);
  }

  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'fastResponseWorkshops' })
  fastResponseWorkshops(@Args() args: NearbyArgs) {
    return this.discoveryService.fastResponseNearby(args);
  }

  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'searchWorkshops' })
  searchWorkshops(
    @Args('search') search: string,
    @Args('categoryId', { nullable: true }) categoryId?: string,
    @Args('city', { nullable: true }) city?: string,
    @Args('limit', { nullable: true }) limit?: number,
  ) {
    return this.discoveryService.searchWorkshops(search, categoryId, city, limit);
  }

  /** Advanced map discovery — bounds OR radius around center + optional filters + Redis TTL cache. */
  @UseOptionalAuth()
  @Query(() => [Workshop], { name: 'workshopsMapDiscovery' })
  workshopsMapDiscovery(@Args() args: WorkshopMapDiscoveryArgs) {
    return this.geospatialService.workshopsMapDiscovery(args);
  }

  /** Cross-entity text search for map UX. */
  @UseOptionalAuth()
  @Query(() => MapSearchResult, { name: 'searchMapEntities' })
  searchMapEntities(
    @Args('query') query: string,
    @Args('limit', { nullable: true }) limit?: number,
  ) {
    return this.geospatialService.searchMapEntities(query, limit ?? 20);
  }

  /** Parts near coordinates (graphql named `nearbyMapParts` — alias for map clients). */
  @UseOptionalAuth()
  @Query(() => [Part], { name: 'nearbyMapParts' })
  nearbyMapParts(@Args() args: NearbyLatLngArgs) {
    return this.geospatialService.nearbyMapParts(args);
  }

  @UseOptionalAuth()
  @Query(() => [WorkshopReview], { name: 'workshopReviews' })
  workshopReviews(@Args('workshopId') workshopId: string) {
    return this.reviewService.listForWorkshop(workshopId);
  }

  @UseOptionalAuth()
  @Query(() => PaginatedWorkshopReviews, { name: 'workshopReviewsPaginated' })
  workshopReviewsPaginated(@Args() args: GetWorkshopReviewsArgs) {
    return this.reviewService.listForWorkshopPaginated(
      args.workshopId,
      args.pagination,
    );
  }

  @UseAuth()
  @Mutation(() => WorkshopReview, { name: 'addWorkshopReview' })
  addWorkshopReview(
    @Args('data') data: AddWorkshopReviewInput,
    @Args('images', { type: () => [GraphQLUpload], nullable: true })
    images: Promise<FileUpload>[] | undefined,
    @Context() ctx: ContextType,
  ) {
    return this.reviewService.addReview(data, images, ctx);
  }

  @UseAuth()
  @Mutation(() => WorkshopReview, { name: 'replyToWorkshopReview' })
  replyToWorkshopReview(
    @Args('data') data: ReplyWorkshopReviewInput,
    @Context() ctx: ContextType,
  ) {
    return this.reviewService.replyToReview(data, ctx);
  }

  @UseAuth()
  @Mutation(() => WorkshopReview, { name: 'updateWorkshopReview' })
  updateWorkshopReview(
    @Args('data') data: UpdateWorkshopReviewInput,
    @Context() ctx: ContextType,
  ) {
    return this.reviewService.updateReview(data, ctx);
  }

  @UseAuth()
  @Mutation(() => Boolean, { name: 'deleteWorkshopReview' })
  deleteWorkshopReview(
    @Args('reviewId') reviewId: string,
    @Context() ctx: ContextType,
  ) {
    return this.reviewService.deleteReview(reviewId, ctx);
  }

  @UseAuth()
  @Mutation(() => WorkshopBooking, { name: 'bookWorkshop' })
  bookWorkshop(
    @Args('data') data: BookWorkshopInput,
    @Context() ctx: ContextType,
  ) {
    return this.bookingService.bookWorkshop(data, ctx);
  }

  @UseAuth()
  @Mutation(() => Workshop)
  restoreWorkshopById(
    @Args() args: GetWorkshopByIdArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.restoreWorkshopById(args, context);
  }

  @UseAuth()
  @Mutation(() => Workshop, { name: 'promoteWorkshop' })
  promoteWorkshop(
    @Args() args: PromoteWorkshopArgs,
    @Context() context: ContextType,
  ) {
    return this.workshopService.promoteWorkshop(args, context);
  }
}
