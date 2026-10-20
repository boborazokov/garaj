import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart';

enum ItemStatusEnum { active, archived }

extension ItemStatusEnumX on ItemStatusEnum {
  String toApiString() {
    switch (this) {
      case ItemStatusEnum.active:
        return "ACTIVE";
      case ItemStatusEnum.archived:
        return "ARCHIVED";
    }
  }

  static ItemStatusEnum fromApiString(String value) {
    switch (value.toUpperCase()) {
      case "ACTIVE":
      case "PENDING_MODERATION":
        return ItemStatusEnum.active;
      case "ARCHIVED":
        return ItemStatusEnum.archived;
      default:
        return ItemStatusEnum.active;
    }
  }
}

class Part {
  final String id;
  final String description;
  final String name;
  final int price;
  final String currency;
  final int quantity;
  final DateTime createdAt;
  final String location;
  final String? region;
  final List<String> images;
  final Seller? seller;
  final CategoryCar? category;
  final CategoryCar? brand;
  final CategoryCar? carModel;
  final int discount;
  final DateTime activeUntil;
  final bool isFavorite;
  final ItemStatusEnum status;
  final bool? condition;
  final String delivery;
  final bool? negotiable;

  /// True while [promotedUntil] is in the future. Used to render the
  /// "Promoted" ribbon on cards and lift the card to the top of feeds.
  final bool isPromoted;
  final DateTime? promotedUntil;
  final String? promotionPlan;
  final int promotionPriority;
  final int viewsCount;

  Part({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.createdAt,
    required this.images,
    required this.description,
    required this.location,
    required this.discount,
    required this.status,
    required this.activeUntil,
    required this.delivery,
    this.condition,
    this.isFavorite = false,
    this.category,
    this.brand,
    this.carModel,
    this.seller,
    this.negotiable,
    this.region,
    this.isPromoted = false,
    this.promotedUntil,
    this.promotionPlan,
    this.promotionPriority = 0,
    this.viewsCount = 0,
  });

  bool get isPromotionActive {
    if (!isPromoted) return false;
    final until = promotedUntil;
    if (until == null) return false;
    return until.isAfter(DateTime.now());
  }

  int get effectivePromotionWeight {
    if (!isPromotionActive) return 0;
    if (promotionPriority > 0) return promotionPriority;
    final plan = promotionPlan;
    if (plan == null) return 1;
    for (final p in ServicePromotionPlan.values) {
      if (p.api == plan) return p.weight;
    }
    return 1;
  }

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: _toInt(json['price']),
        currency: json['currency']?.toString() ?? '',
        quantity: _toInt(json['quantity']),
        isFavorite: json['isFavorite'] ?? false,
        createdAt: _parseDate(json['createdAt']),
        activeUntil: _parseDate(json['activeUntil']),
        location: json['location']?.toString() ?? '',
        region: json['region']?.toString(),
        discount: _toInt(json['discount']),
        status: json['status'] != null
            ? ItemStatusEnumX.fromApiString(json['status'])
            : ItemStatusEnum.archived,
        category: (json['category'] != null)
            ? CategoryCar.fromJson(Map<String, dynamic>.from(json['category']))
            : null,
        brand: (json['brand'] is Map)
            ? CategoryCar.fromJson(Map<String, dynamic>.from(json['brand']))
            : null,
        carModel: (json['carModel'] is Map)
            ? CategoryCar.fromJson(Map<String, dynamic>.from(json['carModel']))
            : null,
        images: _parseImageList(json['images']),
        seller: (json['seller'] != null)
            ? Seller.fromJson(Map<String, dynamic>.from(json['seller']))
            : null,
        condition: json['isNew'],
        delivery:
            getDeliveryStatus(json['deliveryCondition']?.toString() ?? "NA"),
        negotiable: json["isNegotiable"],
        isPromoted: json['isPromoted'] == true,
        promotedUntil: _parseOptionalDate(json['promotedUntil']),
        promotionPlan: json['promotionPlan']?.toString(),
        promotionPriority: _toInt(json['promotionPriority']),
        viewsCount: _toInt(json['viewsCount']));
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'region': region,
      'discount': discount,
      'status': status.toApiString(),
      'category': category,
      'images': images,
      'isFavorite': isFavorite,
      'activeUntil': activeUntil.toIso8601String(),
      'seller': seller?.toJson(),
      'condition': condition,
      'deliveryCondition': delivery,
      'negotiable': negotiable,
      'isPromoted': isPromoted,
      'promotedUntil': promotedUntil?.toIso8601String(),
      'promotionPlan': promotionPlan,
      'promotionPriority': promotionPriority,
    };
  }

  static List<String> _parseImageList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => normalizeStoragePath(e.toString(), mediaBase: fileUrl))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return DateTime.now();
  }

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return null;
  }
}

class Seller {
  final String id;
  final String image;
  final String name;
  final String phone;
  final DateTime createdAt;
  final String? address;
  final bool verified;

  Seller({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.image,
    this.address,
    this.verified = false,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      address: json['address']?.toString(),
      verified: json['verified'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  get avatarUrl => null;

  get imageUrl => null;

  get totalSales => null;

  get rating => null;


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'image': image,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

String getDeliveryStatus(String name) {
  final context = navigatorKey.currentState?.context;
  if (context == null) return "Not available";

  final s = S.of(context);

  switch (name) {
    case "INCLUDED":
      return s.yes;
    case "NOT_INCLUDED":
      return s.no;
    case "UNDER_CONTRACT":
      return s.byAgreement;
    default:
      return "Not available";
  }
}
