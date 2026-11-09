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

  static AdSurface? fromApi(String? raw) {
    final v = (raw ?? '').trim().toUpperCase();
    for (final s in AdSurface.values) {
      if (s.api == v) return s;
    }
    return null;
  }
}

enum AdCampaignStatus {
  active('ACTIVE'),
  paused('PAUSED'),
  expired('EXPIRED'),
  queued('QUEUED');

  const AdCampaignStatus(this.api);
  final String api;

  static AdCampaignStatus fromApi(String? raw) {
    final v = (raw ?? '').trim().toUpperCase();
    for (final s in AdCampaignStatus.values) {
      if (s.api == v) return s;
    }
    return AdCampaignStatus.active;
  }
}

/// Public banner served by the backend `getAdvertisements` query.
class Advertisement {
  Advertisement({
    required this.id,
    required this.type,
    required this.title,
    required this.bannerImageUrl,
    required this.link,
    this.status = AdCampaignStatus.active,
    this.impressionCount = 0,
    this.clickCount = 0,
    this.ctr = 0,
    this.amountPaid = 0,
    this.queuePosition = 0,
    this.plan,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String type;
  final String title;
  final String bannerImageUrl;
  final String link;
  final AdCampaignStatus status;
  final int impressionCount;
  final int clickCount;
  final double ctr;
  final int amountPaid;
  final int queuePosition;
  final String? plan;
  final DateTime? startsAt;
  final DateTime? endsAt;

  AdSurface? get surface => AdSurface.fromApi(type);

  factory Advertisement.fromJson(Map<String, dynamic> json) => Advertisement(
        id: (json['_id'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        bannerImageUrl: (json['bannerImageUrl'] ?? '').toString(),
        link: (json['link'] ?? '').toString(),
        status: AdCampaignStatus.fromApi(json['status']?.toString()),
        impressionCount: (json['impressionCount'] as num?)?.toInt() ?? 0,
        clickCount: (json['clickCount'] as num?)?.toInt() ?? 0,
        ctr: (json['ctr'] as num?)?.toDouble() ?? 0,
        amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
        queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 0,
        plan: json['plan']?.toString(),
        startsAt: _parseDate(json['startsAt']),
        endsAt: _parseDate(json['endsAt']),
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}

class AdSlotInfo {
  AdSlotInfo({
    required this.placement,
    required this.activeCount,
    required this.maxSlots,
    required this.queueLength,
    required this.hasFreeSlot,
  });

  final AdSurface placement;
  final int activeCount;
  final int maxSlots;
  final int queueLength;
  final bool hasFreeSlot;

  factory AdSlotInfo.fromJson(Map<String, dynamic> json) {
    return AdSlotInfo(
      placement: AdSurface.fromApi(json['placement']?.toString()) ??
          AdSurface.brand,
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
      maxSlots: (json['maxSlots'] as num?)?.toInt() ?? 5,
      queueLength: (json['queueLength'] as num?)?.toInt() ?? 0,
      hasFreeSlot: json['hasFreeSlot'] == true,
    );
  }
}
