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
}

export type CategoryType =
  | 'BRAND'
  | 'MODEL'
  | 'PART'
  | 'SERVICE'
  | 'TUNING'
  | 'ANNOUNCEMENT'

export interface CategoryRow {
  _id: string
  name: string
  names: CategoryNames
  iconUrl?: string
  type: CategoryType
  parentId?: string | null
}

export interface AdvertisementRow {
  _id: string
  type: CategoryType
  title: string
  bannerImageUrl: string
  link: string
  createdAt?: string
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
  phone: string
  status: string
  budget?: number
  currency?: string
  location?: string
  createdAt?: string
  author?: { _id: string; name: string; phone?: string }
  brand?: { name: string }
  carModel?: { name: string }
  partCategory?: { name: string }
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
  images?: string[]
  location?: string
  region?: string
  status: ItemStatus
  isPromoted?: boolean
  isNew?: boolean
  isNegotiable?: boolean
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
