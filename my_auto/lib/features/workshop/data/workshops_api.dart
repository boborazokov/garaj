const String workshopCategoriesQuery = r"""
query WorkshopCategories {
  workshopCategories {
    _id
    slug
    name
    names { ru en uz }
    icon
    color
    popular
  }
}
""";

const String workshopDetailsQuery = r"""
query WorkshopDetails($workshopId: ObjectId!) {
  workshopDetails(workshopId: $workshopId) {
    _id
    name
    description
    address
    city
    location
    coverImage
    logo
    gallery
    images
    phone
    telegram
    verified
    premium
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
    open24Hours
    rating
    reviewCount
    fastResponse
    responseTimeMinutes
    serviceRadiusKm
    isOpenNow
    openFrom
    openUntil
    geoLocation { latitude longitude }
    servicePricing { label categorySlug priceFrom priceTo currency }
    weeklySchedule { day closed openTime closeTime }
    categories { _id slug name names { ru en uz } icon color }
    owner { _id name phone }
  }
}
""";

const String getWorkshopsQuery = r"""
query GetWorkshops($pagination: PaginationInput, $search: String, $filter: WorkshopFilterInput) {
  getWorkshops(pagination: $pagination, search: $search, filter: $filter) {
    payload {
      _id
      name
      description
      address
      city
      coverImage
      logo
      gallery
      images
      verified
      rating
      reviewCount
      fastResponse
      isOpenNow
      openFrom
      openUntil
      geoLocation { latitude longitude }
      categories { _id name slug names { ru en uz } icon color }
    }
    totalDocs
    hasNextPage
    page
  }
}
""";

const String nearbyWorkshopsQuery = r"""
query NearbyWorkshops($latitude: Float!, $longitude: Float!, $radiusKm: Float, $limit: Int) {
  nearbyWorkshops(latitude: $latitude, longitude: $longitude, radiusKm: $radiusKm, limit: $limit) {
    _id
    name
    address
    city
    coverImage
    logo
    gallery
    verified
    premium
    hasPickupService
    open24Hours
    isEmergency
    supportedCarBrands
    rating
    reviewCount
    fastResponse
    isOpenNow
    geoLocation { latitude longitude }
    categories { _id name slug icon color }
  }
}
""";

/// Viewport-first workshop discovery (bounds + filters + Redis-backed API).
const String workshopsMapDiscoveryQuery = r"""
query WorkshopsMapDiscovery(
  $latitude: Float!
  $longitude: Float!
  $radiusKm: Float
  $bounds: MapBoundsInput
  $filters: WorkshopFiltersInput
  $limit: Int
) {
  workshopsMapDiscovery(
    latitude: $latitude
    longitude: $longitude
    radiusKm: $radiusKm
    bounds: $bounds
    filters: $filters
    limit: $limit
  ) {
    _id
    name
    address
    city
    coverImage
    logo
    gallery
    verified
    premium
    hasPickupService
    open24Hours
    isEmergency
    supportedCarBrands
    rating
    reviewCount
    fastResponse
    isOpenNow
    openFrom
    openUntil
    phone
    geoLocation { latitude longitude }
    weeklySchedule { day closed openTime closeTime }
    servicePricing { label categorySlug priceFrom priceTo currency }
    categories { _id slug name names { ru en uz } icon color }
  }
}
""";

const String searchMapEntitiesQuery = r"""
query SearchMapEntities($query: String!, $limit: Int) {
  searchMapEntities(query: $query, limit: $limit) {
    workshops {
      _id
      name
      address
      city
      coverImage
      verified
      premium
      rating
      isOpenNow
      geoLocation { latitude longitude }
      categories { slug name }
    }
    services {
      _id
      title
      verified
      isEmergency
      rating
      images
      geoLocation { latitude longitude }
      category { name slug }
    }
    parts {
      _id
      name
      price
      currency
      images
      geoLocation { latitude longitude }
    }
  }
}
""";

const String recommendedWorkshopsQuery = r"""
query RecommendedWorkshops {
  recommendedWorkshops {
    _id
    name
    address
    coverImage
    verified
    rating
    reviewCount
    isOpenNow
    geoLocation { latitude longitude }
    categories { name }
  }
}
""";

const String openNowWorkshopsQuery = r"""
query OpenNowWorkshops($latitude: Float!, $longitude: Float!, $limit: Int) {
  openNowWorkshops(latitude: $latitude, longitude: $longitude, limit: $limit) {
    _id
    name
    address
    coverImage
    rating
    isOpenNow
    geoLocation { latitude longitude }
  }
}
""";

const String searchWorkshopsQuery = r"""
query SearchWorkshops($search: String!, $categoryId: ObjectId, $city: String, $limit: Int) {
  searchWorkshops(search: $search, categoryId: $categoryId, city: $city, limit: $limit) {
    _id
    name
    address
    city
    coverImage
    rating
    verified
    isOpenNow
    categories { name }
  }
}
""";

const String workshopReviewsPaginatedQuery = r"""
query WorkshopReviewsPaginated($workshopId: String!, $pagination: PaginationInput!) {
  workshopReviewsPaginated(workshopId: $workshopId, pagination: $pagination) {
    payload {
      _id
      rating
      text
      images
      createdAt
      ownerReply { text repliedAt }
      user { _id name }
    }
    hasNextPage
    page
    totalDocs
  }
}
""";

const String createWorkshopMutation = r"""
mutation CreateWorkshop($data: WorkshopInput!) {
  createWorkshop(data: $data) {
    _id
    name
  }
}
""";

const String updateWorkshopMutation = r"""
mutation UpdateWorkshop($workshopId: ObjectId!, $data: WorkshopUpdateInput!, $images: [Upload!]) {
  updateWorkshopById(workshopId: $workshopId, data: $data, images: $images) {
    _id
  }
}
""";

const String deleteWorkshopMutation = r"""
mutation DeleteWorkshop($workshopId: ObjectId!) {
  deleteWorkshopById(workshopId: $workshopId) {
    _id
  }
}
""";

const String bookWorkshopMutation = r"""
mutation BookWorkshop($data: BookWorkshopInput!) {
  bookWorkshop(data: $data) {
    _id
    status
    scheduledAt
  }
}
""";

const String addWorkshopReviewMutation = r"""
mutation AddWorkshopReview($data: AddWorkshopReviewInput!) {
  addWorkshopReview(data: $data) {
    _id
    rating
    text
  }
}
""";

const String updateWorkshopReviewMutation = r"""
mutation UpdateWorkshopReview($data: UpdateWorkshopReviewInput!) {
  updateWorkshopReview(data: $data) {
    _id
    rating
    text
  }
}
""";

const String deleteWorkshopReviewMutation = r"""
mutation DeleteWorkshopReview($reviewId: String!) {
  deleteWorkshopReview(reviewId: $reviewId)
}
""";

const String promoteWorkshopMutation = r"""
mutation PromoteWorkshop($workshopId: ObjectId!, $plan: ServicePromotionPlanEnum!) {
  promoteWorkshop(workshopId: $workshopId, plan: $plan) {
    _id
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
    premium
  }
}
""";
