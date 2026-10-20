/// GraphQL documents for Orders / Requests marketplace feature.

const String getSellerMatchingOrdersOverviewQuery = r"""
query GetSellerMatchingOrdersOverview {
  getSellerMatchingOrdersOverview {
    totalMatchingOrders
    categories {
      categoryId
      orderCount
      listingsCount
      category {
        _id
        key
        icon
        names { en ru uz }
      }
    }
  }
}
""";

const String getOrdersQuery = r"""
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
  }
}
""";

const String getOrderByIdQuery = r"""
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

const String getOrderResponsesQuery = r"""
query GetOrderResponses($orderId: ObjectId!) {
  getOrderResponses(orderId: $orderId) {
    _id
    text
    offeredPrice
    deliveryDays
    isAccepted
    createdAt
    seller { _id name phone }
    part {
      _id
      name
      images
      price
      currency
    }
  }
}
""";

const String createOrderMutation = r"""
mutation CreateOrder($data: OrderInput!) {
  createOrder(data: $data) {
    _id
    title
    status
    createdAt
  }
}
""";

const String respondToOrderMutation = r"""
mutation RespondToOrder($data: RespondToOrderInput!) {
  respondToOrder(data: $data) {
    _id
    text
    offeredPrice
    deliveryDays
    createdAt
    seller { _id name phone }
    part {
      _id
      name
      images
      price
      currency
    }
  }
}
""";

const String closeOrderMutation = r"""
mutation CloseOrder($orderId: ObjectId!) {
  closeOrderById(orderId: $orderId) {
    _id
    status
  }
}
""";

const String reopenOrderMutation = r"""
mutation ReopenOrder($orderId: ObjectId!) {
  reopenOrderById(orderId: $orderId) {
    _id
    status
  }
}
""";

const String deleteOrderMutation = r"""
mutation DeleteOrder($orderId: ObjectId!) {
  deleteOrderById(orderId: $orderId) {
    _id
  }
}
""";

const String orderUpdatedSubscription = r"""
subscription OrderUpdated($orderId: ObjectId!) {
  orderUpdated(orderId: $orderId) {
    _id
    status
    responseCount
    viewsCount
  }
}
""";

const String orderResponseAddedSubscription = r"""
subscription OrderResponseAdded($orderId: ObjectId!) {
  orderResponseAdded(orderId: $orderId) {
    _id
    text
    offeredPrice
    deliveryDays
    createdAt
    seller { _id name phone }
    part {
      _id
      name
      images
      price
      currency
    }
  }
}
""";
