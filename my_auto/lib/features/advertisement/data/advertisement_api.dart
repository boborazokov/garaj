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
