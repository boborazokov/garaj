/// GraphQL operations for the Orders (Announcements) feature.
const String GET_ORDERS = r"""
query GetOrders(
  $pagination: PaginationInput!,
  $filter: OrderFilterInput,
  $search: String,
  $sort: SortOrderEnum,
  $viewerRegion: String,
) {
  getOrders(
    pagination: $pagination,
    filter: $filter,
    search: $search,
    sort: $sort,
    viewerRegion: $viewerRegion,
  ) {
    payload {
      _id
      title
      description
      phone
      location
      region
      budget
      currency
      status
      isPromoted
      createdAt
      author { _id name phone }
      brand { _id name iconUrl }
      carModel { _id name iconUrl }
      partCategory { _id name iconUrl }
      images
      urgency
    }
    totalDocs
    totalPages
    page
    limit
    hasNextPage
    hasPrevPage
    nextPage
    prevPage
  }
}
""";

const String CREATE_ORDER = r"""
mutation CreateOrder($data: OrderInput!) {
  createOrder(data: $data) {
    _id
    title
    status
    createdAt
  }
}
""";

const String CLOSE_ORDER = r"""
mutation CloseOrder($orderId: ObjectId!) {
  closeOrderById(orderId: $orderId) {
    _id
    status
  }
}
""";

const String DELETE_ORDER = r"""
mutation DeleteOrder($orderId: ObjectId!) {
  deleteOrderById(orderId: $orderId) {
    _id
  }
}
""";

const String GET_ORDER_BY_ID = r"""
query GetOrderById($orderId: ObjectId!) {
  getOrderById(orderId: $orderId) {
    _id
    title
    description
    phone
    location
    region
    budget
    currency
    status
    isPromoted
    createdAt
    author { _id name phone }
    brand { _id name iconUrl }
    carModel { _id name iconUrl }
    partCategory { _id name iconUrl }
    images
    urgency
  }
}
""";
