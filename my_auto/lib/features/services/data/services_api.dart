const String nearbyServicesQuery = r"""
query NearbyServices($latitude: Float!, $longitude: Float!, $radiusKm: Float, $limit: Int) {
  nearbyServices(latitude: $latitude, longitude: $longitude, radiusKm: $radiusKm, limit: $limit) {
    _id
    title
    description
    address
    phone
    verified
    isEmergency
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
    rating
    reviewCount
    features
    images
    openFrom
    openUntil
    geoLocation { latitude longitude }
    category { _id name slug }
    owner { _id name phone }
  }
}
""";

const String topRatedServicesQuery = r"""
query TopRatedServices {
  topRatedServices {
    _id
    title
    address
    verified
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
    rating
    reviewCount
    images
    geoLocation { latitude longitude }
    category { name }
  }
}
""";

const String serviceDetailsQuery = r"""
query ServiceDetails($serviceId: String!) {
  serviceDetails(serviceId: $serviceId) {
    _id
    title
    description
    address
    phone
    telegram
    verified
    isEmergency
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
    rating
    reviewCount
    features
    images
    openFrom
    openUntil
    geoLocation { latitude longitude }
    category { _id name slug iconUrl }
    owner { _id name phone }
  }
}
""";

const String promoteServiceMutation = r"""
mutation PromoteService($serviceId: ObjectId!, $plan: ServicePromotionPlanEnum!) {
  promoteService(serviceId: $serviceId, plan: $plan) {
    _id
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
  }
}
""";

const String serviceReviewsQuery = r"""
query ServiceReviews($serviceId: String!) {
  serviceReviews(serviceId: $serviceId) {
    _id
    rating
    text
    createdAt
    user { _id name }
  }
}
""";

const String nearbyProductsMapQuery = r"""
query NearbyProducts($latitude: Float!, $longitude: Float!, $radiusKm: Float, $limit: Int) {
  nearbyProducts(latitude: $latitude, longitude: $longitude, radiusKm: $radiusKm, limit: $limit) {
    _id
    name
    price
    currency
    images
    geoLocation { latitude longitude }
  }
}
""";

const String nearbyOrdersMapQuery = r"""
query NearbyOrders($latitude: Float!, $longitude: Float!, $radiusKm: Float, $limit: Int) {
  nearbyOrders(latitude: $latitude, longitude: $longitude, radiusKm: $radiusKm, limit: $limit) {
    _id
    title
    budget
    currency
    geoLocation { latitude longitude }
  }
}
""";

const String bookServiceMutation = r"""
mutation BookService($data: BookServiceInput!) {
  bookService(data: $data) {
    _id
    status
    scheduledAt
  }
}
""";

const String favoriteServiceMutation = r"""
mutation FavoriteService($serviceId: String!) {
  favoriteService(serviceId: $serviceId)
}
""";

const String addServiceReviewMutation = r"""
mutation AddServiceReview($data: AddReviewInput!) {
  addReview(data: $data) {
    _id
    rating
    text
  }
}
""";
