import 'package:my_auto/features/advertisement/domain/advertisement.dart';

enum AdPlan {
  day('DAY', 1),
  week('WEEK', 7),
  month('MONTH', 30),
  quarter('QUARTER', 90);

  const AdPlan(this.api, this.days);
  final String api;
  final int days;

  static AdPlan? fromApi(String raw) {
    final v = raw.trim().toUpperCase();
    for (final p in AdPlan.values) {
      if (p.api == v) return p;
    }
    return null;
  }
}

class AdvertisementPlanPrice {
  AdvertisementPlanPrice({
    required this.placement,
    required this.plan,
    required this.amount,
    required this.currency,
    required this.days,
  });

  final AdSurface placement;
  final AdPlan plan;
  final int amount;
  final String currency;
  final int days;

  factory AdvertisementPlanPrice.fromJson(Map<String, dynamic> json) {
    final placement = AdSurface.values.firstWhere(
      (s) => s.api == (json['placement'] ?? '').toString(),
      orElse: () => AdSurface.brand,
    );
    final plan = AdPlan.fromApi((json['plan'] ?? '').toString()) ?? AdPlan.week;
    return AdvertisementPlanPrice(
      placement: placement,
      plan: plan,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] ?? 'UZS').toString(),
      days: (json['days'] as num?)?.toInt() ?? plan.days,
    );
  }
}
