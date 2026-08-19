import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/add/uploudImageService.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/add/api/index.dart';
import 'package:my_auto/features/profile/screens/my_products/api/index.dart';

enum DeleveryTupe { INCLUDED, NOT_INCLUDED, UNDER_CONTRACT }

class AddPartProvider extends ChangeNotifier {
  String? id;
  String? title;
  String? description;
  String? categoryId;
  String? categoriesName;
  int? price;
  int? quantity;
  int? discount;
  String? currency;
  bool negotiable = false;
  String? condition;
  String? delivery;

  List<File> images = [];
  bool isLoading = false;
  double uploadProgress = 0.0;
  List<String> networkImages = [];

  final UploadService _uploadService = UploadService();
  List<dynamic> allImages = [];

  Future<void> addImages(List<File> files) async {
    for (final file in files) {
      if (images.length + networkImages.length >= 5) break;
      images.add(file);
    }
    _refreshAllImages();
  }

  void addNetworkImages(List<String> urls) {
    networkImages = urls;
    _refreshAllImages();
  }

  void removeImage(dynamic image) {
    images.remove(image);
    networkImages.remove(image);
    _refreshAllImages();
  }

  void fillFromPart(Part part) {
    id = part.id;
    title = part.name;
    description = part.description;
    categoryId = part.category?.id;
    categoriesName = part.category?.name;
    price = part.price;
    quantity = part.quantity;
    discount = part.discount;
    currency = part.currency;
    negotiable = part.negotiable ?? false;
    condition = part.condition == true ? "newPart" : "used";
    delivery = _convertDeliveryEnumToLocal(part.delivery);

    networkImages = part.images;
    _refreshAllImages();

    notifyListeners();
  }

  void _refreshAllImages() {
    allImages = [
      ...networkImages,
      ...images,
    ];

    allImages = allImages.toSet().toList();
    notifyListeners();
  }

  void reset() {
    id = null;
    title = null;
    description = null;
    categoryId = null;
    price = null;
    quantity = null;
    discount = null;
    currency = null;
    negotiable = false;
    condition = null;
    delivery = null;
    images.clear();
    networkImages.clear();
    allImages.clear();
    uploadProgress = 0.0;
    notifyListeners();
  }

  void setFormData({
    required String title,
    required String description,
    required String categoryId,
    required int price,
    required int quantity,
    required int discount,
    required String currency,
    required String categoriesName,
    bool negotiable = false,
    String? condition,
    String? delivery,
  }) {
    this.title = title;
    this.description = description;
    this.categoryId = categoryId;
    this.price = price;
    this.quantity = quantity;
    this.discount = discount;
    this.currency = currency;
    this.negotiable = negotiable;
    this.condition = condition;
    this.categoriesName = categoriesName;
    this.delivery = delivery;
    notifyListeners();
  }

  void removeNetworkImage(String url) {
    networkImages.remove(url);
    notifyListeners();
  }

  String? _validateForPublish() {
    if (title == null || title!.trim().isEmpty) {
      return 'Part name is required';
    }
    if (categoryId == null || categoryId!.trim().isEmpty) {
      return 'Category is required';
    }
    if (currency == null || currency!.trim().isEmpty) {
      return 'Currency is required';
    }
    return null;
  }

  Future<bool> savePart() async {
    if (id == null) {
      final validationError = _validateForPublish();
      if (validationError != null) {
        debugPrint("Validation error: $validationError");
        return false;
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      if (id == null) {
        await _publishPart();
      } else {
        await _updatePart();
      }
      return true;
    } catch (e) {
      debugPrint("Error saving part: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _publishPart() async {
    uploadProgress = 0.0;
    notifyListeners();

    try {
      final body = {
        "name": title,
        "description": description,
        "category": categoryId,
        "price": price ?? 0,
        "quantity": quantity ?? 1,
        "currency": currency,
        "isNegotiable": negotiable,
        "isNew": getConditionValue(condition),
        "deliveryCondition": getDeliveryType(delivery),
      };

      final String newId = await _createPartOnServer(body);
      id = newId;

      await _uploadImages(newId);
      reset();
    } catch (e) {
      debugPrint("Publish error: $e");
      rethrow;
    } finally {
      uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> _updatePart() async {
    if (id == null) throw Exception("Part ID is null");

    final uploadedUrls = images.isNotEmpty
        ? await _uploadService.uploadFilesWithProgress(
            files: images,
            targetId: id!,
            targetType: "part",
            onProgress: (p) {
              uploadProgress = p;
              notifyListeners();
            },
          )
        : [];

    final allImages = [...networkImages, ...uploadedUrls];

    await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(updatePartById),
        variables: {
          "partId": id,
          "data": {
            "name": title,
            "description": description,
            "category": categoryId,
            "price": price,
            "quantity": quantity,
            "currency": currency,
            "isNegotiable": negotiable,
            "isNew": getConditionValue(condition),
            "deliveryCondition": getDeliveryType(delivery),
          },
          "images": [],
        },
      ),
    );
  }

  Future<void> _uploadImages(String targetId) async {
    List<String> uploadedUrls = [];
    if (images.isNotEmpty) {
      uploadedUrls = await _uploadService.uploadFilesWithProgress(
        files: images,
        targetId: targetId,
        targetType: "part",
        onProgress: (progress) {
          uploadProgress = progress;
          notifyListeners();
        },
      );

      if (uploadedUrls.isNotEmpty) {
        final variables = {
          "partId": targetId,
          "data": {},
          "images": uploadedUrls,
        };

        await GraphQLConfig.client().mutate(
          MutationOptions(
            document: gql(updatePartById),
            variables: variables,
          ),
        );
      }
    }
  }

  Future<String> _createPartOnServer(Map<String, dynamic> data) async {
    final variables = {"data": data, "images": []};
    final result = await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(CREATE_PARTS),
        variables: variables,
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    final id = result.data?['createPart']?['_id'];
    if (id == null) throw Exception("Failed to create part");
    return id;
  }

  String _convertDeliveryEnumToLocal(String? type) {
    switch (type) {
      case "INCLUDED":
        return "haveDelivery";
      case "NOT_INCLUDED":
        return "noDelivery";
      case "UNDER_CONTRACT":
        return "byAgreement";
      default:
        return "noDelivery";
    }
  }
}

String? getDeliveryType(String? delivery) {
  if (delivery == null) return null;

  switch (delivery) {
    case "haveDelivery":
      return DeleveryTupe.INCLUDED.name;
    case "noDelivery":
      return DeleveryTupe.NOT_INCLUDED.name;
    case "byAgreement":
      return DeleveryTupe.UNDER_CONTRACT.name;
    default:
      return DeleveryTupe.NOT_INCLUDED.name;
  }
}

bool getConditionValue(String? condition) {
  if (condition == null) return false;
  return condition == "newPart";
}
