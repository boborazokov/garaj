const String recommendedProductsQuery = r'''
query RecommendedProducts($limit: Int, $city: String) {
  recommendedProducts(limit: $limit, city: $city) {
    _id
    name
    description
    price
    currency
    quantity
    createdAt
    location
    region
    images
    isNegotiable
    isNew
    isPromoted
    promotedUntil
    status
    deliveryCondition
    category { _id name }
    brand { _id name }
    carModel { _id name }
    seller { _id name phone image createdAt }
  }
}
''';

const String trendingProductsQuery = r'''
query TrendingProducts($limit: Int, $city: String) {
  trendingProducts(limit: $limit, city: $city) {
    _id
    name
    description
    price
    currency
    quantity
    createdAt
    location
    region
    images
    isNegotiable
    isNew
    isPromoted
    promotedUntil
    status
    deliveryCondition
    category { _id name }
    brand { _id name }
    carModel { _id name }
    seller { _id name phone image createdAt }
  }
}
''';

const String nearbyProductsQuery = r'''
query NearbyProducts($limit: Int, $region: String) {
  nearbyProducts(limit: $limit, region: $region) {
    _id
    name
    description
    price
    currency
    quantity
    createdAt
    location
    region
    images
    isNegotiable
    isNew
    isPromoted
    promotedUntil
    status
    deliveryCondition
    category { _id name }
    brand { _id name }
    carModel { _id name }
    seller { _id name phone image createdAt }
  }
}
''';

const String recentlyViewedProductsQuery = r'''
query RecentlyViewedProducts($limit: Int) {
  recentlyViewedProducts(limit: $limit) {
    _id
    name
    description
    price
    currency
    quantity
    createdAt
    location
    region
    images
    isNegotiable
    isNew
    isPromoted
    promotedUntil
    status
    deliveryCondition
    category { _id name }
    brand { _id name }
    carModel { _id name }
    seller { _id name phone image createdAt }
  }
}
''';

const String similarProductsQuery = r'''
query SimilarProducts($productId: ObjectId!, $limit: Int) {
  similarProducts(productId: $productId, limit: $limit) {
    _id
    name
    description
    price
    currency
    quantity
    createdAt
    location
    region
    images
    isNegotiable
    isNew
    isPromoted
    promotedUntil
    status
    deliveryCondition
    category { _id name }
    brand { _id name }
    carModel { _id name }
    seller { _id name phone image createdAt }
  }
}
''';

const String newArrivalsQuery = r'''
query NewArrivals($limit: Int) {
  newArrivals(limit: $limit) {
    _id
    name
    description
    price
    currency
    quantity
    createdAt
    location
    region
    images
    isNegotiable
    isNew
    isPromoted
    promotedUntil
    status
    deliveryCondition
    category { _id name }
    brand { _id name }
    carModel { _id name }
    seller { _id name phone image createdAt }
  }
}
''';

const String searchProductsQuery = r'''
query SearchProducts(
  $query: String
  $category: String
  $city: String
  $minPrice: Float
  $maxPrice: Float
  $limit: Int
  $offset: Int
) {
  searchProducts(
    query: $query
    category: $category
    city: $city
    minPrice: $minPrice
    maxPrice: $maxPrice
    limit: $limit
    offset: $offset
  ) {
    total
    limit
    offset
    processingTimeMs
    payload {
      _id
      name
      description
      price
      currency
      quantity
      createdAt
      location
      region
      images
      isNegotiable
      isNew
      isPromoted
      promotedUntil
      status
      deliveryCondition
      category { _id name }
      brand { _id name }
      carModel { _id name }
      seller { _id name phone image createdAt }
    }
  }
}
''';
