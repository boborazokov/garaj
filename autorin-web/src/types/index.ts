export type ItemStatus =
  | 'ACTIVE'
  | 'ARCHIVED'
  | 'PENDING_MODERATION'
  | 'REJECTED'

export interface CategoryNames {
  en: string
  ru: string
  uz: string
}

export interface CategoryRef {
  _id: string
  name: string
  names?: CategoryNames
  iconUrl?: string
  type?: CategoryType
  parentId?: string | null
}

export type CategoryType =
  | 'BRAND'
  | 'MODEL'
  | 'PART'
  | 'SERVICE'
  | 'TUNING'
  | 'ANNOUNCEMENT'

export type AdminPartsSort =
  | 'NEWEST'
  | 'OLDEST'
  | 'VIEWS'
  | 'PRICE_ASC'
  | 'PRICE_DESC'
  | 'RECOMMENDED'

export type AdminWorkshopsSort =
  | 'NEWEST'
  | 'OLDEST'
  | 'VIEWS'
  | 'RECOMMENDED'

export type AdminOrdersSort =
  | 'NEWEST'
  | 'OLDEST'
  | 'BUDGET_ASC'
  | 'BUDGET_DESC'
  | 'RECOMMENDED'

export type OrderStatus = 'ACTIVE' | 'CLOSED' | 'CANCELLED'

export interface WorkshopCategoryRef {
  _id: string
  slug?: string
  name?: string
  popular?: boolean
  names?: CategoryNames
}

export type WorkshopPromotionPlan =
  | 'BASIC'
  | 'STANDARD'
  | 'PREMIUM'
  | 'VIP'
  | 'TOP'

export interface WorkshopRow {
  _id: string
  name: string
  description?: string
  phone?: string
  city?: string
  address?: string
  location?: string
  coverImage?: string
  logo?: string
  gallery?: string[]
  status: ItemStatus
  verified?: boolean
  isPromoted?: boolean
  promotedUntil?: string | null
  promotionPlan?: WorkshopPromotionPlan | null
  viewCount?: number
  phoneClickCount?: number
  bookingCount?: number
  rating?: number
  reviewCount?: number
  createdAt?: string
  categories?: WorkshopCategoryRef[]
  owner?: Seller
}

export interface PaginatedWorkshops {
  payload: WorkshopRow[]
  page: number
  totalPages: number
  totalDocs: number
  hasNextPage: boolean
  nextPage: number | null
}

export interface CategoryRow {
  _id: string
  name: string
  names: CategoryNames
  iconUrl?: string
  type: CategoryType
  parentId?: string | null
}

export type AdvertisementStatus = "ACTIVE" | "PAUSED" | "EXPIRED" | "QUEUED"

export type AdvertisementPlan = "DAY" | "WEEK" | "MONTH" | "QUARTER"

export interface AdvertisementPlanPrice {
  placement: CategoryType
  plan: AdvertisementPlan
  amount: number
  currency: string
  days: number
  priority: number
}

export type PromotionPlan =
  | "BASIC"
  | "STANDARD"
  | "PREMIUM"
  | "VIP"
  | "TOP"

export interface PromotionPlanPrice {
  plan: PromotionPlan
  amount: number
  currency: string
  days: number
  priority: number
}

export interface AdvertisementRow {
  _id: string
  type: CategoryType
  title: string
  bannerImageUrl: string
  link: string
  startsAt?: string | null
  endsAt?: string | null
  status: AdvertisementStatus
  impressionCount: number
  clickCount: number
  ctr: number
  isFree: boolean
  plan?: AdvertisementPlan | null
  amountPaid?: number
  queuePosition?: number
  createdAt?: string
  updatedAt?: string
}

export interface PaginatedAdvertisements {
  payload: AdvertisementRow[]
  page: number
  totalPages: number
  hasNextPage: boolean
  nextPage: number | null
}

export interface OrderRow {
  _id: string
  title: string
  description?: string
  phone: string
  status: OrderStatus
  budget?: number
  currency?: string
  location?: string
  region?: string
  images?: string[]
  isPromoted?: boolean
  promotedUntil?: string | null
  urgency?: string
  year?: number | null
  createdAt?: string
  author?: { _id: string; name: string; phone?: string }
  brand?: CategoryRef
  carModel?: CategoryRef
  partCategory?: CategoryRef
}

export interface OrderOfferRow {
  _id: string
  text: string
  offeredPrice?: number | null
  deliveryDays?: number | null
  isAccepted: boolean
  createdAt?: string
  seller?: { _id: string; name: string; phone?: string }
  part?: { _id: string; name: string; price?: number; currency?: string } | null
}

export interface PaginatedOrders {
  payload: OrderRow[]
  page: number
  totalPages: number
  hasNextPage: boolean
  nextPage: number | null
}

export interface Seller {
  _id: string
  name: string
  phone: string
  address?: string
}

export interface Part {
  _id: string
  name: string
  description: string
  price: number
  currency: string
  quantity?: number
  viewsCount?: number
  images?: string[]
  location?: string
  region?: string
  status: ItemStatus
  isPromoted?: boolean
  promotedUntil?: string | null
  isNew?: boolean
  isNegotiable?: boolean
  deliveryCondition?: "INCLUDED" | "NOT_INCLUDED" | "UNDER_CONTRACT"
  category?: CategoryRef
  brand?: CategoryRef
  carModel?: CategoryRef
  seller?: Seller
  moderationNote?: string | null
  createdAt?: string
}

export interface PaginatedParts {
  payload: Part[]
  page: number
  totalPages: number
  totalDocs: number
  hasNextPage: boolean
  nextPage: number | null
}

export interface UserRow {
  _id: string
  name: string
  phone: string
  role: string
  verified?: boolean | null
  createdAt?: string
}

export interface PaginatedUsers {
  payload: UserRow[]
  page: number
  totalPages: number
  hasNextPage: boolean
  nextPage: number | null
}

export interface AdminStats {
  usersCount: number
  partsCount: number
  activePartsCount: number
  pendingModerationCount: number
  ordersCount: number
  workshopsCount: number
  activeWorkshopsCount: number
}

export interface AppSettings {
  productModerationEnabled: boolean
  supportEmail?: string | null
  supportPhone?: string | null
}

export interface AdminDailyReportRow {
  date: string
  visits: number
  newUsers: number
  partsPublished: number
  ordersPublished: number
}

export interface AdminDailyReport {
  rows: AdminDailyReportRow[]
  days: number
  totalVisits: number
  totalNewUsers: number
  totalPartsPublished: number
  totalOrdersPublished: number
  todayVisits: number
  todayPartsPublished: number
  todayOrdersPublished: number
  todayNewUsers: number
}

// ---------------------------------------------------------------------------
// Chat (admin <-> sellers)
// ---------------------------------------------------------------------------

export interface ChatParticipant {
  _id: string
  name?: string | null
  phone?: string | null
  verified?: boolean | null
}

export interface ChatConversation {
  _id: string
  participants: ChatParticipant[]
  lastMessageText?: string | null
  lastMessageSender?: string | null
  lastMessageAt?: string | null
  unread?: number
  createdAt?: string
  updatedAt?: string
}

export interface PaginatedConversations {
  payload: ChatConversation[]
  page: number
  totalDocs: number
  totalPages: number
  hasNextPage: boolean
  nextPage: number | null
}

export interface ChatMessage {
  _id: string
  text?: string | null
  images?: string[] | null
  readBy?: string[] | null
  createdAt: string
  updatedAt?: string | null
  sender: ChatParticipant
  replyTo?: string | null
  replyToText?: string | null
  replyToSenderName?: string | null
  replyToSenderId?: string | null
  voiceUrl?: string | null
  voiceDurationMs?: number | null
}

export interface PaginatedMessages {
  payload: ChatMessage[]
  page: number
  totalDocs: number
  totalPages: number
  hasNextPage: boolean
  nextPage: number | null
}
