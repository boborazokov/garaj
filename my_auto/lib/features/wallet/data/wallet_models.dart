import 'dart:convert';

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
    this.currency = 'UZS',
    this.referenceType,
    this.referenceId,
    this.note,
    this.metaJson,
    this.createdAt,
  });

  final String id;
  final String type;
  final String pool;
  final int amount;
  final String status;
  final String currency;
  final String? referenceType;
  final String? referenceId;
  final String? note;
  final String? metaJson;
  final DateTime? createdAt;

  Map<String, dynamic> get meta {
    final raw = metaJson?.trim();
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return const {};
  }

  factory WalletTx.fromJson(Map<String, dynamic> json) {
    return WalletTx(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      pool: json['pool']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'UZS',
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      note: json['note']?.toString(),
      metaJson: json['metaJson']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

