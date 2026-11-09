import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/promotion/data/promotion_api.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';

enum PromotionTargetType {
  part('PART'),
  order('ORDER'),
  service('SERVICE'),
  workshop('WORKSHOP');

  const PromotionTargetType(this.api);
  final String api;
}

class PromotionPlanPrice {
  const PromotionPlanPrice({
    required this.plan,
    required this.amount,
    required this.currency,
    required this.days,
    required this.priority,
  });

  final ServicePromotionPlan plan;
  final int amount;
  final String currency;
  final int days;
  final int priority;

  factory PromotionPlanPrice.fromJson(Map<String, dynamic> json) {
    return PromotionPlanPrice(
      plan: ServicePromotionPlanX.fromApi(json['plan']?.toString()) ??
          ServicePromotionPlan.basic,
      amount: _toInt(json['amount']),
      currency: (json['currency'] ?? 'UZS').toString(),
      days: _toInt(json['days']),
      priority: _toInt(json['priority']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

extension ServicePromotionPlanX on ServicePromotionPlan {
  static ServicePromotionPlan? fromApi(String? api) {
    if (api == null || api.isEmpty) return null;
    final normalized = api.toUpperCase();
    for (final p in ServicePromotionPlan.values) {
      if (p.api == normalized) return p;
    }
    return null;
  }
}

class PromotionRepository {
  final _client = GraphQLConfig.client();

  Future<List<PromotionPlanPrice>> fetchPlanPrices() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(promotionPlanPricesQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );
    if (result.hasException) return const [];
    final raw = result.data?['promotionPlanPrices'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => PromotionPlanPrice.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Pay for a plan; backend marks payment PAID and boosts the listing.
  Future<bool> purchasePromotion({
    required PromotionTargetType targetType,
    required String targetId,
    required ServicePromotionPlan plan,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(purchasePromotionMutation),
        variables: {
          'targetType': targetType.api,
          'targetId': targetId,
          'plan': plan.api,
        },
      ),
    );
    if (result.hasException) return false;
    final payload = result.data?['purchasePromotion'];
    if (payload is! Map) return false;
    return payload['status']?.toString() == 'PAID' &&
        payload['promotedAt'] != null;
  }
}

final promotionRepository = PromotionRepository();
