class WalletBalance {
  const WalletBalance({
    required this.id,
    required this.mainBalance,
    required this.bonusBalance,
    required this.availableTotal,
    required this.currency,
  });

  final String id;
  final int mainBalance;
  final int bonusBalance;
  final int availableTotal;
  final String currency;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      id: json['_id']?.toString() ?? '',
      mainBalance: (json['mainBalance'] as num?)?.toInt() ?? 0,
      bonusBalance: (json['bonusBalance'] as num?)?.toInt() ?? 0,
      availableTotal: (json['availableTotal'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'UZS',
    );
  }
}

class WalletTx {
  const WalletTx({
    required this.id,
    required this.type,
    required this.pool,
    required this.amount,
    required this.status,
    this.note,
    this.createdAt,
  });

  final String id;
  final String type;
  final String pool;
  final int amount;
  final String status;
  final String? note;
  final DateTime? createdAt;

  factory WalletTx.fromJson(Map<String, dynamic> json) {
    return WalletTx(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      pool: json['pool']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

enum PromotionTargetType {
  part('PART'),
  order('ORDER'),
  service('SERVICE'),
  workshop('WORKSHOP');

  const PromotionTargetType(this.api);
  final String api;
}
