/// Public banner feed query. Filtered by `type` so the client only pays for
/// the slots it actually renders.
const String getAdvertisementsQuery = r'''
query GetAdvertisements($filter: AdvertisementFilterInput) {
  getAdvertisements(filter: $filter) {
    _id
    type
    title
    bannerImageUrl
    link
  }
}
''';

const String advertisementPlanPricesQuery = r'''
query AdvertisementPlanPrices {
  advertisementPlanPrices {
    placement
    plan
    amount
    currency
    days
    priority
  }
}
''';

const String advertisementSlotInfoQuery = r'''
query AdvertisementSlotInfo($type: CategoryTypeEnum!) {
  advertisementSlotInfo(type: $type) {
    placement
    activeCount
    maxSlots
    queueLength
    hasFreeSlot
  }
}
''';

const String myAdvertisementsQuery = r'''
query MyAdvertisements {
  myAdvertisements {
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
    amountPaid
    queuePosition
    plan
  }
}
''';

const String purchaseAdvertisementMutation = r'''
mutation PurchaseAdvertisement(
  $type: CategoryTypeEnum!
  $plan: AdvertisementPlanEnum!
  $title: String!
  $link: String!
  $bannerImageUrl: String!
) {
  purchaseAdvertisement(
    type: $type
    plan: $plan
    title: $title
    link: $link
    bannerImageUrl: $bannerImageUrl
  ) {
    _id
    type
    title
    status
    queuePosition
    amountPaid
    endsAt
  }
}
''';

const String pauseMyAdvertisementMutation = r'''
mutation PauseMyAdvertisement($advertisementId: ObjectId!) {
  pauseMyAdvertisement(advertisementId: $advertisementId) {
    _id
    status
  }
}
''';

const String recordAdvertisementImpressionMutation = r'''
mutation RecordAdvertisementImpression($advertisementId: ObjectId!) {
  recordAdvertisementImpression(advertisementId: $advertisementId) {
    _id
    impressionCount
  }
}
''';

const String recordAdvertisementClickMutation = r'''
mutation RecordAdvertisementClick($advertisementId: ObjectId!) {
  recordAdvertisementClick(advertisementId: $advertisementId) {
    _id
    clickCount
  }
}
''';
