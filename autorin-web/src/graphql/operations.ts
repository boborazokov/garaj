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
      isNew
      isNegotiable
      moderationNote
      category { _id name }
      brand { _id name }
      carModel { _id name }
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
        createdAt
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
    }
  }
`

export const DELETE_ADVERTISEMENT = gql`
  mutation DeleteAdvertisement($advertisementId: ObjectId!) {
    deleteAdvertisement(advertisementId: $advertisementId)
  }
`

export const ADMIN_LIST_ORDERS = gql`
  query AdminListOrders($pagination: PaginationInput, $search: String) {
    adminListOrders(pagination: $pagination, search: $search) {
      payload {
        _id
        title
        phone
        status
        budget
        currency
        location
        createdAt
        author { _id name phone }
        brand { name }
        carModel { name }
        partCategory { name }
      }
      page
      totalPages
      hasNextPage
      nextPage
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
  ) {
    adminListParts(
      pagination: $pagination
      search: $search
      categoryType: $categoryType
    ) {
      payload {
        _id
        name
        price
        currency
        status
        createdAt
        images
        category { name type }
        seller { name phone }
      }
      page
      totalPages
      hasNextPage
      nextPage
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
