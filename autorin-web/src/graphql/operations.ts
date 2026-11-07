import { gql } from '@apollo/client'

export const GET_PARTS = gql`
  query GetParts(
    $pagination: PaginationInput!
    $search: String
    $filter: PartFilterInput
    $sort: SortOrderEnum
  ) {
    getParts(
      pagination: $pagination
      search: $search
      filter: $filter
      sort: $sort
    ) {
      payload {
        _id
        name
        description
        price
        currency
        images
        location
        region
        status
        isPromoted
        isNew
        viewsCount
        quantity
        brand { _id name }
        carModel { _id name }
        category { _id name }
      }
      page
      totalPages
      totalDocs
      hasNextPage
      nextPage
    }
  }
`

export const GET_PART_BY_ID = gql`
  query GetPartById($partId: ObjectId!) {
    getPartById(partId: $partId) {
      _id
      name
      description
      price
      currency
      images
      location
      region
      status
      isPromoted
      promotedUntil
      isNew
      isNegotiable
      deliveryCondition
      viewsCount
      quantity
      moderationNote
      category {
        _id
        name
        names { uz ru en }
      }
      brand {
        _id
        name
        names { uz ru en }
      }
      carModel {
        _id
        name
        names { uz ru en }
      }
      seller { _id name phone address }
      createdAt
    }
  }
`

export const GET_CATEGORIES = gql`
  query GetCategories($filter: CategoryFilterInput) {
    getCategories(filter: $filter) {
      _id
      name
      names {
        en
        ru
        uz
      }
      iconUrl
      type
      parentId
    }
  }
`

/** Products filter: PART taxonomy only (avoids Apollo cache clash with other getCategories calls). */
export const GET_PRODUCT_CATEGORIES = gql`
  query GetProductCategories {
    getCategories(filter: { type: PART }) {
      _id
      name
      names {
        en
        ru
        uz
      }
      iconUrl
      type
      parentId
    }
  }
`

export const CREATE_CATEGORY = gql`
  mutation CreateCategory($data: CategoryInput!) {
    createCategory(data: $data) {
      _id
      name
      names {
        en
        ru
        uz
      }
      type
      iconUrl
      parentId
    }
  }
`

export const UPDATE_CATEGORY = gql`
  mutation UpdateCategory($categoryId: ObjectId!, $data: CategoryInput!) {
    updateCategory(categoryId: $categoryId, data: $data) {
      _id
      name
      names {
        en
        ru
        uz
      }
      type
      iconUrl
      parentId
    }
  }
`

export const DELETE_CATEGORY = gql`
  mutation DeleteCategory($categoryId: ObjectId!) {
    deleteCategory(categoryId: $categoryId)
  }
`

export const ADMIN_LIST_ADVERTISEMENTS = gql`
  query AdminListAdvertisements(
    $pagination: PaginationInput
    $filter: AdvertisementFilterInput
  ) {
    adminListAdvertisements(pagination: $pagination, filter: $filter) {
      payload {
        _id
        type
        title
        bannerImageUrl
        link
        startsAt
        endsAt
        status
        impressionCount
        clickCount
        ctr
        isFree
        createdAt
        updatedAt
      }
      page
      totalPages
      hasNextPage
      nextPage
    }
  }
`

export const CREATE_ADVERTISEMENT = gql`
  mutation CreateAdvertisement($data: AdvertisementInput!) {
    createAdvertisement(data: $data) {
      _id
      title
      type
      bannerImageUrl
      link
      startsAt
      endsAt
      status
      impressionCount
      clickCount
      ctr
      isFree
    }
  }
`

export const UPDATE_ADVERTISEMENT = gql`
  mutation UpdateAdvertisement($advertisementId: ObjectId!, $data: AdvertisementInput!) {
    updateAdvertisement(advertisementId: $advertisementId, data: $data) {
      _id
      title
      type
      bannerImageUrl
      link
      startsAt
      endsAt
      status
      impressionCount
      clickCount
      ctr
      isFree
    }
  }
`

export const DELETE_ADVERTISEMENT = gql`
  mutation DeleteAdvertisement($advertisementId: ObjectId!) {
    deleteAdvertisement(advertisementId: $advertisementId)
  }
`

export const ADMIN_LIST_ORDERS = gql`
  query AdminListOrders(
    $pagination: PaginationInput
    $search: String
    $status: OrderStatusEnum
    $partCategoryId: ObjectId
    $authorId: ObjectId
    $createdFrom: DateTime
    $createdTo: DateTime
    $isPromoted: Boolean
    $sort: AdminOrdersSortEnum
  ) {
    adminListOrders(
      pagination: $pagination
      search: $search
      status: $status
      partCategoryId: $partCategoryId
      authorId: $authorId
      createdFrom: $createdFrom
      createdTo: $createdTo
      isPromoted: $isPromoted
      sort: $sort
    ) {
      payload {
        _id
        title
        description
        phone
        status
        budget
        currency
        location
        region
        images
        isPromoted
        promotedUntil
        urgency
        year
        createdAt
        author { _id name phone }
        brand {
          _id
          name
          names { en ru uz }
        }
        carModel {
          _id
          name
          names { en ru uz }
        }
        partCategory {
          _id
          name
          names { en ru uz }
          type
          parentId
        }
      }
      page
      totalPages
      hasNextPage
      nextPage
    }
  }
`

export const GET_ORDER_RESPONSES = gql`
  query GetOrderResponses($orderId: ObjectId!) {
    getOrderResponses(orderId: $orderId) {
      _id
      text
      offeredPrice
      deliveryDays
      isAccepted
      createdAt
      seller { _id name phone }
      part { _id name price currency }
    }
  }
`

export const SIGN_UP = gql`
  mutation SignUp($data: SignUpInput!) {
    signUp(data: $data) {
      token
      correctCode
    }
  }
`

export const CONFIRM_SIGN_UP = gql`
  mutation ConfirmSignUp($token: String!, $code: String!) {
    confirmSignUp(token: $token, code: $code) {
      token
      accessToken
      refreshToken
      user {
        _id
        name
        phone
        role
      }
    }
  }
`

export const SIGN_IN = gql`
  query SignIn($data: SignInInput!) {
    signIn(data: $data) {
      token
      accessToken
      refreshToken
      user {
        _id
        name
        phone
        role
      }
    }
  }
`

export const GET_ADMIN_STATS = gql`
  query GetAdminStats {
    getAdminStats {
      usersCount
      partsCount
      activePartsCount
      pendingModerationCount
      ordersCount
      workshopsCount
      activeWorkshopsCount
    }
  }
`

export const GET_ADMIN_DAILY_REPORT = gql`
  query GetAdminDailyReport($days: Int) {
    getAdminDailyReport(days: $days) {
      days
      totalVisits
      totalNewUsers
      totalPartsPublished
      totalOrdersPublished
      todayVisits
      todayPartsPublished
      todayOrdersPublished
      todayNewUsers
      rows {
        date
        visits
        newUsers
        partsPublished
        ordersPublished
      }
    }
  }
`

export const GET_APP_SETTINGS = gql`
  query GetAppSettings {
    getAppSettings {
      productModerationEnabled
      supportEmail
      supportPhone
    }
  }
`

export const SET_CONTACT_INFO = gql`
  mutation SetContactInfo($supportEmail: String!, $supportPhone: String!) {
    setContactInfo(supportEmail: $supportEmail, supportPhone: $supportPhone) {
      supportEmail
      supportPhone
    }
  }
`

export const SET_MODERATION = gql`
  mutation SetProductModeration($enabled: Boolean!) {
    setProductModerationEnabled(enabled: $enabled) {
      productModerationEnabled
    }
  }
`

export const ADMIN_LIST_USERS = gql`
  query AdminListUsers($pagination: PaginationInput, $search: String) {
    adminListUsers(pagination: $pagination, search: $search) {
      payload {
        _id
        name
        phone
        role
        verified
        createdAt
      }
      page
      totalPages
      hasNextPage
      nextPage
    }
  }
`

export const ADMIN_SET_USER_ROLE = gql`
  mutation AdminSetUserRole($userId: ObjectId!, $role: UserRoleEnum!) {
    adminSetUserRole(userId: $userId, role: $role) {
      _id
      role
    }
  }
`

export const GET_PENDING_PARTS = gql`
  query GetPendingParts($pagination: PaginationInput, $search: String) {
    getPendingParts(pagination: $pagination, search: $search) {
      payload {
        _id
        name
        price
        currency
        images
        status
        createdAt
        seller { _id name phone }
        category { name }
      }
      page
      totalPages
      hasNextPage
      nextPage
    }
  }
`

export const ADMIN_LIST_PARTS = gql`
  query AdminListParts(
    $pagination: PaginationInput
    $search: String
    $categoryType: CategoryTypeEnum
    $status: ItemStatusEnum
    $category: ObjectId
    $sellerId: ObjectId
    $minPrice: Float
    $maxPrice: Float
    $createdFrom: DateTime
    $createdTo: DateTime
    $isPromoted: Boolean
    $sort: AdminPartsSortEnum
  ) {
    adminListParts(
      pagination: $pagination
      search: $search
      categoryType: $categoryType
      status: $status
      category: $category
      sellerId: $sellerId
      minPrice: $minPrice
      maxPrice: $maxPrice
      createdFrom: $createdFrom
      createdTo: $createdTo
      isPromoted: $isPromoted
      sort: $sort
    ) {
      payload {
        _id
        name
        price
        currency
        quantity
        viewsCount
        status
        isPromoted
        promotedUntil
        createdAt
        images
        category {
          _id
          name
          type
          names { uz ru en }
        }
        seller { _id name phone }
      }
      page
      totalPages
      totalDocs
      hasNextPage
      nextPage
    }
  }
`

export const DELETE_PART = gql`
  mutation DeletePart($partId: ObjectId!) {
    deletePartById(partId: $partId) {
      _id
    }
  }
`

export const ADMIN_SET_PART_RECOMMENDED = gql`
  mutation AdminSetPartRecommended($partId: ObjectId!, $recommended: Boolean!) {
    adminSetPartRecommended(partId: $partId, recommended: $recommended) {
      _id
      isPromoted
      promotedUntil
    }
  }
`

export const ADMIN_SET_PART_VIEWS_COUNT = gql`
  mutation AdminSetPartViewsCount($partId: ObjectId!, $viewsCount: Int!) {
    adminSetPartViewsCount(partId: $partId, viewsCount: $viewsCount) {
      _id
      viewsCount
    }
  }
`

export const ADMIN_LIST_WORKSHOPS = gql`
  query AdminListWorkshops(
    $pagination: PaginationInput
    $search: String
    $status: ItemStatusEnum
    $categoryId: ObjectId
    $ownerId: ObjectId
    $createdFrom: DateTime
    $createdTo: DateTime
    $isPromoted: Boolean
    $sort: AdminWorkshopsSortEnum
  ) {
    adminListWorkshops(
      pagination: $pagination
      search: $search
      status: $status
      categoryId: $categoryId
      ownerId: $ownerId
      createdFrom: $createdFrom
      createdTo: $createdTo
      isPromoted: $isPromoted
      sort: $sort
    ) {
      payload {
        _id
        name
        description
        phone
        city
        address
        location
        coverImage
        logo
        gallery
        status
        verified
        isPromoted
        promotedUntil
        promotionPlan
        viewCount
        phoneClickCount
        bookingCount
        rating
        reviewCount
        createdAt
        categories {
          _id
          slug
          name
          names { uz ru en }
        }
        owner { _id name phone }
      }
      page
      totalPages
      totalDocs
      hasNextPage
      nextPage
    }
  }
`

export const WORKSHOP_CATEGORIES = gql`
  query WorkshopCategories {
    workshopCategories {
      _id
      slug
      name
      popular
      names { uz ru en }
    }
  }
`

export const DELETE_WORKSHOP = gql`
  mutation DeleteWorkshop($workshopId: ObjectId!) {
    deleteWorkshopById(workshopId: $workshopId) {
      _id
    }
  }
`

export const ADMIN_SET_WORKSHOP_RECOMMENDED = gql`
  mutation AdminSetWorkshopRecommended($workshopId: ObjectId!, $recommended: Boolean!) {
    adminSetWorkshopRecommended(workshopId: $workshopId, recommended: $recommended) {
      _id
      isPromoted
      promotedUntil
    }
  }
`

export const DELETE_ORDER = gql`
  mutation DeleteOrder($orderId: ObjectId!) {
    deleteOrderById(orderId: $orderId) {
      _id
    }
  }
`

export const CLOSE_ORDER = gql`
  mutation CloseOrder($orderId: ObjectId!) {
    closeOrderById(orderId: $orderId) {
      _id
      status
    }
  }
`

export const REOPEN_ORDER = gql`
  mutation ReopenOrder($orderId: ObjectId!) {
    reopenOrderById(orderId: $orderId) {
      _id
      status
    }
  }
`

export const ADMIN_SET_ORDER_RECOMMENDED = gql`
  mutation AdminSetOrderRecommended($orderId: ObjectId!, $recommended: Boolean!) {
    adminSetOrderRecommended(orderId: $orderId, recommended: $recommended) {
      _id
      isPromoted
      promotedUntil
    }
  }
`

export const APPROVE_PART = gql`
  mutation ApprovePart($partId: ObjectId!, $note: String) {
    approvePart(partId: $partId, note: $note) {
      _id
      status
    }
  }
`

export const REJECT_PART = gql`
  mutation RejectPart($partId: ObjectId!, $note: String) {
    rejectPart(partId: $partId, note: $note) {
      _id
      status
    }
  }
`

// ---------------------------------------------------------------------------
// Chat (admin <-> sellers)
// ---------------------------------------------------------------------------

export const CHAT_GET_CONVERSATIONS = gql`
  query AdminGetConversations($pagination: PaginationInput) {
    getConversations(pagination: $pagination) {
      payload {
        _id
        lastMessageText
        lastMessageSender
        lastMessageAt
        unread
        createdAt
        updatedAt
        participants {
          _id
          name
          phone
          verified
        }
      }
      totalDocs
      page
      totalPages
      hasNextPage
      nextPage
    }
  }
`

export const ADMIN_SET_USER_VERIFIED = gql`
  mutation AdminSetUserVerified($userId: ObjectId!, $verified: Boolean!) {
    adminSetUserVerified(userId: $userId, verified: $verified) {
      _id
      name
      phone
      verified
    }
  }
`

export const CHAT_GET_MESSAGES = gql`
  query AdminGetMessages($conversationId: ObjectId!, $pagination: PaginationInput) {
    getMessages(conversationId: $conversationId, pagination: $pagination) {
      payload {
        _id
        text
        images
        readBy
        createdAt
        updatedAt
        replyTo
        replyToText
        replyToSenderName
        replyToSenderId
        voiceUrl
        voiceDurationMs
        sender {
          _id
          name
          phone
        }
      }
      totalDocs
      page
      totalPages
      hasNextPage
      nextPage
    }
  }
`

export const CHAT_SEND_MESSAGE = gql`
  mutation AdminSendMessage($data: SendMessageInput!) {
    sendMessage(data: $data) {
      _id
      text
      images
      readBy
      createdAt
      replyTo
      replyToText
      replyToSenderName
      replyToSenderId
      voiceUrl
      voiceDurationMs
      sender {
        _id
        name
        phone
      }
    }
  }
`

export const CHAT_MARK_AS_READ = gql`
  mutation AdminMarkAsRead($conversationId: ObjectId!) {
    markAsRead(conversationId: $conversationId) {
      _id
    }
  }
`
