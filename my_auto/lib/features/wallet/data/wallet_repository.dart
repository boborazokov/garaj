import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/promotion/data/promotion_repository.dart'
    show PromotionTargetType;
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/wallet/data/wallet_api.dart';
import 'package:my_auto/features/wallet/data/wallet_models.dart';

class WalletInsufficientFundsException implements Exception {
  WalletInsufficientFundsException([this.message = 'INSUFFICIENT_WALLET_BALANCE']);
  final String message;

  @override
  String toString() => message;
}

class PromotionPlanPrice {
  const PromotionPlanPrice({
    required this.plan,
    required this.amount,
    required this.days,
    required this.priority,
  });

  final ServicePromotionPlan plan;
  final int amount;
  final int days;
  final int priority;
}

class WalletRepository {
  GraphQLClient get _client => GraphQLConfig.client();

  Future<WalletBalance?> fetchWallet() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myWalletQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return null;
    final raw = result.data?['myWallet'];
    if (raw is! Map) return null;
    return WalletBalance.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<List<WalletTx>> fetchTransactions({int limit = 40}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myWalletTransactionsQuery),
        variables: {'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['myWalletTransactions'] as List? ?? [];
    return list
        .map((e) => WalletTx.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<ServicePromotionPlan, PromotionPlanPrice>> fetchPlanPrices() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(promotionPlanPricesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return {};
    final list = result.data?['promotionPlanPrices'] as List? ?? [];
    final map = <ServicePromotionPlan, PromotionPlanPrice>{};
    for (final raw in list) {
      if (raw is! Map) continue;
      final api = raw['plan']?.toString().toUpperCase() ?? '';
      ServicePromotionPlan? plan;
      for (final p in ServicePromotionPlan.values) {
        if (p.api == api) {
          plan = p;
          break;
        }
      }
      if (plan == null) continue;
      map[plan] = PromotionPlanPrice(
        plan: plan,
        amount: (raw['amount'] as num?)?.toInt() ?? 0,
        days: (raw['days'] as num?)?.toInt() ?? 0,
        priority: (raw['priority'] as num?)?.toInt() ?? plan.weight,
      );
    }
    return map;
  }

  Future<WalletTx?> topUp(int amount) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(createWalletTopupIntentMutation),
        variables: {'amount': amount},
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final raw = result.data?['createWalletTopupIntent'];
    if (raw is! Map) return null;
    return WalletTx.fromJson(Map<String, dynamic>.from(raw));
  }

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
    if (result.hasException) {
      final msg = result.exception.toString();
      if (msg.contains('INSUFFICIENT_WALLET_BALANCE')) {
        throw WalletInsufficientFundsException(msg);
      }
      throw Exception(msg);
    }
    final status = result.data?['purchasePromotion']?['status']?.toString();
    return status == 'PAID';
  }

  Future<bool> cancelPromotion({
    required PromotionTargetType targetType,
    required String targetId,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(cancelPromotionMutation),
        variables: {
          'targetType': targetType.api,
          'targetId': targetId,
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return result.data?['cancelPromotion'] == true;
  }
}

final walletRepository = WalletRepository();
