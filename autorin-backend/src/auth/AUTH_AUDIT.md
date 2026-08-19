# Auth endpoint audit (GlobalAuthGuard + secure-by-default)

Legend:
- **Public** — `@Public()`, no JWT
- **OptionalAuth** — `@UseOptionalAuth()`, guest OK + token enriches response
- **Protected** — default / `@UseAuth()`, JWT required (401 without token)
- **WsAuth** — `@UseWsAuth()` on GraphQL subscriptions (JWT on WS handshake)

Field resolvers (`@ResolveField` on Workshop/Part/Order) inherit parent query auth — no separate decorator.

---

## Public

| Endpoint | Type | Why |
|----------|------|-----|
| `signUp` | Mutation | Onboarding |
| `confirmSignUp` | Mutation | OTP / registration |
| `signIn` | Query | Login |
| `getCategories` | Query | Static catalog |
| `getCategoryTree` | Query | Brand/model picker |
| `workshopCategories` | Query | Static taxonomy |
| `serviceCategories` | Query | Static taxonomy |
| `getViewsCount` | Query | Public view counter |
| `GET /debug/firebase` | REST | Ops only; 404 in prod unless `ALLOW_FIREBASE_DEBUG_ENDPOINT=true` |

---

## OptionalAuth (guest browse + personalization when logged in)

| Endpoint | Type | Why |
|----------|------|-----|
| `searchProducts` | Query | Marketplace search |
| `recommendedProducts` | Query | Home feed |
| `similarProducts` | Query | PDP recommendations |
| `trendingProducts` | Query | Trending |
| `nearbyProducts` (recommendation) | Query | Geo feed |
| `recentlyViewedProducts` | Query | Needs userId when logged in |
| `newArrivals` | Query | Public listing |
| `recommendedOrders` | Query | Order feed |
| `getPartById` | Query | Product detail |
| `getParts` | Query | Parts catalog |
| `getWorkshopById` / `workshopDetails` | Query | Workshop detail |
| `getWorkshops` | Query | Workshop list |
| `nearbyWorkshops` | Query | Discovery |
| `recommendedWorkshops` | Query | Discovery |
| `popularNearbyWorkshops` | Query | Discovery |
| `openNowWorkshops` | Query | Discovery |
| `fastResponseWorkshops` | Query | Discovery |
| `searchWorkshops` | Query | Discovery |
| `workshopsMapDiscovery` | Query | Map |
| `searchMapEntities` | Query | Map search |
| `nearbyMapParts` | Query | Map parts |
| `workshopReviews` | Query | Public reviews list |
| `nearbyServices` | Query | Service discovery |
| `nearbyEmergencyServices` | Query | Emergency discovery |
| `serviceDetails` | Query | Service detail |
| `getServices` | Query | Service catalog |
| `topRatedServices` | Query | Discovery |
| `nearbyProducts` (service resolver) | Query | Geo parts |
| `nearbyOrders` | Query | Public active orders feed |
| `serviceReviews` | Query | Public reviews |
| `getOrders` | Query | Marketplace orders (ACTIVE for guests) |
| `getOrderById` | Query | Order detail (guests: non-cancelled) |
| `trackActivity` | Mutation | Anonymous analytics |

---

## Protected (JWT required)

| Endpoint | Type | Why |
|----------|------|-----|
| `getProfile` | Query | Private profile |
| `updateProfile` | Mutation | User settings |
| `trackActivityAuth` | Mutation | Authenticated analytics |
| `createPart` / `updatePartById` / `deletePartById` / `restorePartById` / `promotePartById` | Mutation | Seller CRUD |
| `getFavorites` / `addToFavorites` / `removeFromFavorites` | Query/Mutation | Private list |
| `createCategory` | Mutation | Admin/catalog write |
| `createWorkshop` / `updateWorkshopById` / `deleteWorkshopById` / `restoreWorkshopById` | Mutation | Owner CRUD |
| `addWorkshopReview` / `replyToWorkshopReview` / `bookWorkshop` | Mutation | User actions |
| `myWorkshopBookings` | Query | Private bookings |
| `createService` / `bookService` / `addReview` / `favoriteService` | Mutation | User actions |
| `myServiceBookings` | Query | Private bookings |
| `createOrder` / `updateOrderById` / `closeOrderById` / `deleteOrderById` | Mutation | Order owner |
| `getOrderResponses` | Query | Order author or participating seller only (service check) |
| `respondToOrder` | Mutation | Seller bid |
| `registerDeviceToken` / `removeDeviceToken` | Mutation | Push tokens |
| `getConversations` / `createConversation` / `markAsRead` / `deleteConversationForMe` | Query/Mutation | Chat |
| `getMessages` / `sendMessage` / `deleteMessageForMe` / `updateMessage` / `setTyping` | Query/Mutation | Chat |
| `POST /upload/single` / `POST /upload/multiple` | REST | File upload |

---

## WebSocket subscriptions (WsAuth + domain checks)

| Endpoint | Why |
|----------|-----|
| `conversationUpdated` | Per-user inbox |
| `messageReceived` | Participant check |
| `typingStatus` | Participant check |
| `unreadCountChanged` | Per-user |
| `orderResponseAdded` | Order author or responding seller |

---

## Not exposed (no GraphQL operations)

- `AdvertisementResolver` — no queries/mutations registered
- `TrendingModule` — background jobs only
