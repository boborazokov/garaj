const String GET_ITEMS_BY_CATEGORY = r"""
query GetParts(
  $pagination: PaginationInput!,
  $search: String,
  $filter: PartFilterInput,
  $sort: SortOrderEnum,
  $viewerRegion: String,
) {
  getParts(
    pagination: $pagination,
    search: $search,
    filter: $filter,
    sort: $sort,
    viewerRegion: $viewerRegion,
  ) {
    payload {
      _id
      category { _id name }
      brand { _id name }
      carModel { _id name }
      description
      currency
      deliveryCondition
      images
      isNegotiable
      isNew
      isPromoted
      promotedUntil
      promotionPlan
      promotionPriority
      viewsCount
      location
      region
      name
      price
      status
      createdAt
      seller {
        _id
        name
        image
        createdAt
        phone
        address
      }
    }
    limit
    nextPage
    page
    prevPage
    totalDocs
    totalPages
    hasPrevPage
    hasNextPage
  }
}
""";

const String GET_PRODUCT_BY_ID = r"""
query GetPartById($partId: ObjectId!) {
  getPartById(partId: $partId) {
    _id
    category { _id iconUrl icon key names { en ru uz } }
    brand { _id name }
    carModel { _id name }
    currency
    description
    images
    status
    name
    activeUntil
    price
    deliveryCondition
    isNew
    isNegotiable
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
    viewsCount
    location
    region
    quantity
    createdAt
    seller {
      _id
      name
      createdAt
      phone
      address
      image
      verified
    }
  }
}
""";

const String SET_FAVORITE = r"""
mutation Mutation($favorite: FavoriteInput!) {
  addToFavorites(favorite: $favorite) {
    partsIds
  }
}
""";

const String REMOVE_FAVORITE = r"""
mutation RemoveFromFavorites($favorite: FavoriteInput!) {
  removeFromFavorites(favorite: $favorite) {
    partsIds
  }
}
""";

const String GET_FAVORITE_PARTS = r"""
query GetFavoriteParts($pagination: PaginationInput!) {
  getParts(
    pagination: $pagination,
    filter: { onlyFavorites: true },
  ) {
    payload {
      _id
      name
      price
      currency
      images
      isFavorite
      isNew
      isPromoted
      promotedUntil
      isNegotiable
      location
      category { _id name }
      brand { _id name }
      carModel { _id name }
    }
    totalPages
    hasNextPage
  }
}
""";
