/// Surface where the banner is shown. Aligned 1:1 with the backend
/// `CategoryTypeEnum` so admin uploads in the web console pick which screen
/// the banner targets — `BRAND` for the home shell, `PART` for product lists,
/// `SERVICE` for workshops, etc.
enum AdSurface {
  brand('BRAND'),
  model('MODEL'),
  part('PART'),
  service('SERVICE'),
  tuning('TUNING'),
  announcement('ANNOUNCEMENT');

  const AdSurface(this.api);
  final String api;
}

/// Public banner served by the backend `getAdvertisements` query.
class Advertisement {
  Advertisement({
    required this.id,
    required this.type,
    required this.title,
    required this.bannerImageUrl,
    required this.link,
  });

  final String id;
  final String type;
  final String title;
  final String bannerImageUrl;
  final String link;

  factory Advertisement.fromJson(Map<String, dynamic> json) => Advertisement(
        id: (json['_id'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        bannerImageUrl: (json['bannerImageUrl'] ?? '').toString(),
        link: (json['link'] ?? '').toString(),
      );
}
