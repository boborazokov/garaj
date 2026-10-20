import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_auto/features/create_product/domain/entities/product_photo.dart';

export 'product_photo.dart';

enum CreateProductStep { photos, vehicle, info, price, preview }

enum ProductCondition { newPart, used }

enum DeliveryOption { included, notIncluded, byAgreement }

extension DeliveryOptionX on DeliveryOption {
  String get chipKey {
    switch (this) {
      case DeliveryOption.included:
        return 'haveDelivery';
      case DeliveryOption.byAgreement:
        return 'byAgreement';
      case DeliveryOption.notIncluded:
        return 'noDelivery';
    }
  }

  static DeliveryOption fromChipKey(String key) {
    switch (key) {
      case 'haveDelivery':
        return DeliveryOption.included;
      case 'byAgreement':
        return DeliveryOption.byAgreement;
      default:
        return DeliveryOption.notIncluded;
    }
  }

  /// GraphQL `deliveryCondition` value.
  String get apiValue {
    switch (this) {
      case DeliveryOption.included:
        return 'INCLUDED';
      case DeliveryOption.byAgreement:
        return 'UNDER_CONTRACT';
      case DeliveryOption.notIncluded:
        return 'NOT_INCLUDED';
    }
  }
}

class VehicleSelection extends Equatable {
  const VehicleSelection({
    this.brandId,
    this.brandName,
    this.modelId,
    this.modelName,
    this.partCategoryId,
    this.partCategoryName,
    this.year,
  });

  final String? brandId;
  final String? brandName;
  final String? modelId;
  final String? modelName;
  final String? partCategoryId;
  final String? partCategoryName;
  final int? year;

  VehicleSelection copyWith({
    String? brandId,
    String? brandName,
    String? modelId,
    String? modelName,
    String? partCategoryId,
    String? partCategoryName,
    int? year,
  }) {
    return VehicleSelection(
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      partCategoryId: partCategoryId ?? this.partCategoryId,
      partCategoryName: partCategoryName ?? this.partCategoryName,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toJson() => {
        'brandId': brandId,
        'brandName': brandName,
        'modelId': modelId,
        'modelName': modelName,
        'partCategoryId': partCategoryId,
        'partCategoryName': partCategoryName,
        'year': year,
      };

  factory VehicleSelection.fromJson(Map<String, dynamic> json) {
    return VehicleSelection(
      brandId: json['brandId'] as String?,
      brandName: json['brandName'] as String?,
      modelId: json['modelId'] as String?,
      modelName: json['modelName'] as String?,
      partCategoryId: json['partCategoryId'] as String?,
      partCategoryName: json['partCategoryName'] as String?,
      year: json['year'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        brandId,
        brandName,
        modelId,
        modelName,
        partCategoryId,
        partCategoryName,
        year,
      ];
}

class CreateProductDraft extends Equatable {
  const CreateProductDraft({
    this.editingPartId,
    this.step = CreateProductStep.photos,
    this.photos = const [],
    this.vehicle = const VehicleSelection(),
    this.title = '',
    this.description = '',
    this.condition = ProductCondition.used,
    this.delivery = DeliveryOption.notIncluded,
    this.price,
    this.currency = 'UZS',
    this.negotiable = true,
    this.quantity = 1,
    this.location = '',
    this.region = '',
    this.mapPoint,
    this.tags = const [],
    this.updatedAt,
  });

  final String? editingPartId;
  final CreateProductStep step;
  final List<ProductPhoto> photos;
  final VehicleSelection vehicle;
  final String title;
  final String description;
  final ProductCondition condition;
  final DeliveryOption delivery;
  final int? price;
  final String currency;
  final bool negotiable;
  final int quantity;
  final String location;
  final String region;
  final LatLng? mapPoint;
  final List<String> tags;
  final DateTime? updatedAt;

  String? get categoryId =>
      vehicle.partCategoryId ?? vehicle.modelId;

  bool get hasPhotos => photos.isNotEmpty;

  ProductPhoto? get coverPhoto => photos.isEmpty ? null : photos.first;

  List<String> get validationWarnings {
    final w = <String>[];
    if (photos.isEmpty) w.add('Add at least one photo');
    if (title.trim().length < 3) w.add('Title is too short');
    if (categoryId == null || categoryId!.isEmpty) {
      w.add('Select vehicle or category');
    }
    if (region.trim().isEmpty) w.add('Select region');
    if (price == null || price! <= 0) w.add('Set a price');
    if (currency.isEmpty) w.add('Select currency');
    return w;
  }

  bool get canPublish => validationWarnings.isEmpty;

  /// True when the user has entered anything worth restoring later.
  bool get hasMeaningfulProgress =>
      hasPhotos ||
      title.trim().length >= 3 ||
      (price != null && price! > 0) ||
      description.trim().isNotEmpty ||
      vehicle.brandId != null ||
      (vehicle.partCategoryId != null &&
          vehicle.partCategoryId!.isNotEmpty);

  CreateProductDraft copyWith({
    String? editingPartId,
    CreateProductStep? step,
    List<ProductPhoto>? photos,
    VehicleSelection? vehicle,
    String? title,
    String? description,
    ProductCondition? condition,
    DeliveryOption? delivery,
    int? price,
    String? currency,
    bool? negotiable,
    int? quantity,
    String? location,
    String? region,
    LatLng? mapPoint,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return CreateProductDraft(
      editingPartId: editingPartId ?? this.editingPartId,
      step: step ?? this.step,
      photos: photos ?? this.photos,
      vehicle: vehicle ?? this.vehicle,
      title: title ?? this.title,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      delivery: delivery ?? this.delivery,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      negotiable: negotiable ?? this.negotiable,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      region: region ?? this.region,
      mapPoint: mapPoint ?? this.mapPoint,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'editingPartId': editingPartId,
      'step': step.name,
      'photos': photos
          .map((p) => {
                'id': p.id,
                'path': p.file?.path,
                'networkUrl': p.networkUrl,
              })
          .toList(),
      'vehicle': vehicle.toJson(),
      'title': title,
      'description': description,
      'condition': condition.name,
      'delivery': delivery.name,
      'price': price,
      'currency': currency,
      'negotiable': negotiable,
      'quantity': quantity,
      'location': location,
      'region': region,
      'mapLat': mapPoint?.latitude,
      'mapLng': mapPoint?.longitude,
      'tags': tags,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CreateProductDraft.fromJson(Map<String, dynamic> json) {
    final photoList = (json['photos'] as List?) ?? [];
    return CreateProductDraft(
      editingPartId: json['editingPartId'] as String?,
      step: _stepFromJson(json['step'] as String?),
      photos: photoList.map((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        final path = m['path'] as String?;
        return ProductPhoto(
          id: m['id'] as String? ?? path ?? '',
          file: path != null ? File(path) : null,
          networkUrl: m['networkUrl'] as String?,
        );
      }).toList(),
      vehicle: VehicleSelection.fromJson(
        Map<String, dynamic>.from(json['vehicle'] as Map? ?? {}),
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      condition: ProductCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => ProductCondition.used,
      ),
      delivery: DeliveryOption.values.firstWhere(
        (e) => e.name == json['delivery'],
        orElse: () => DeliveryOption.notIncluded,
      ),
      price: json['price'] as int?,
      currency: json['currency'] as String? ?? 'UZS',
      negotiable: json['negotiable'] != false,
      quantity: json['quantity'] as int? ?? 1,
      location: json['location'] as String? ?? '',
      region: json['region'] as String? ?? '',
      mapPoint: json['mapLat'] != null && json['mapLng'] != null
          ? LatLng(
              (json['mapLat'] as num).toDouble(),
              (json['mapLng'] as num).toDouble(),
            )
          : null,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        editingPartId,
        step,
        photos,
        vehicle,
        title,
        description,
        condition,
        delivery,
        price,
        currency,
        negotiable,
        quantity,
        location,
        region,
        mapPoint,
        tags,
        updatedAt,
      ];
}

CreateProductStep _stepFromJson(String? name) {
  if (name == 'location') return CreateProductStep.preview;
  return CreateProductStep.values.firstWhere(
    (e) => e.name == name,
    orElse: () => CreateProductStep.photos,
  );
}
