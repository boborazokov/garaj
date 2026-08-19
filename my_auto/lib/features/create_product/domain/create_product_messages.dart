import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/generated/l10n.dart';

/// Stable error codes emitted by [CreateProductBloc] for UI localization.
abstract final class CreateProductErrorCodes {
  static const signInRequired = 'create_product/sign_in';
  static const serverUnreachable = 'create_product/server';
  static const categoryRequired = 'create_product/category';
  static const offlinePublish = 'create_product/offline_publish';
  static const warnNoPhotos = 'create_product/warn_no_photos';
  static const warnTitleShort = 'create_product/warn_title_short';
  static const warnNoCategory = 'create_product/warn_no_category';
  static const warnNoPrice = 'create_product/warn_no_price';
  static const warnNoCurrency = 'create_product/warn_no_currency';
  static const duplicateTitle = 'create_product/duplicate_title';
}

List<String> createProductValidationErrorCodes(CreateProductDraft draft) {
  final codes = <String>[];
  if (draft.photos.isEmpty) codes.add(CreateProductErrorCodes.warnNoPhotos);
  if (draft.title.trim().length < 3) {
    codes.add(CreateProductErrorCodes.warnTitleShort);
  }
  if (draft.categoryId == null || draft.categoryId!.isEmpty) {
    codes.add(CreateProductErrorCodes.warnNoCategory);
  }
  if (draft.price == null || draft.price! <= 0) {
    codes.add(CreateProductErrorCodes.warnNoPrice);
  }
  if (draft.currency.isEmpty) codes.add(CreateProductErrorCodes.warnNoCurrency);
  return codes;
}

String localizeCreateProductError(S s, String message) {
  if (message.contains('\n')) {
    return message
        .split('\n')
        .map((line) => localizeCreateProductError(s, line.trim()))
        .join('\n');
  }
  switch (message) {
    case CreateProductErrorCodes.signInRequired:
      return s.createProductErrorSignIn;
    case CreateProductErrorCodes.serverUnreachable:
      return s.createProductErrorServer;
    case CreateProductErrorCodes.categoryRequired:
      return s.createProductErrorCategory;
    case CreateProductErrorCodes.offlinePublish:
      return s.createProductOfflinePublish;
    case CreateProductErrorCodes.warnNoPhotos:
      return s.createProductWarnNoPhotos;
    case CreateProductErrorCodes.warnTitleShort:
      return s.createProductWarnTitleShort;
    case CreateProductErrorCodes.warnNoCategory:
      return s.createProductWarnNoCategory;
    case CreateProductErrorCodes.warnNoPrice:
      return s.createProductWarnNoPrice;
    case CreateProductErrorCodes.warnNoCurrency:
      return s.createProductWarnNoCurrency;
    case CreateProductErrorCodes.duplicateTitle:
      return s.createProductDuplicateTitle;
    default:
      return message;
  }
}

/// Localized validation hints for the create-listing preview step.
List<String> createProductValidationMessages(S s, CreateProductDraft draft) {
  final messages = <String>[];
  if (draft.photos.isEmpty) messages.add(s.createProductWarnNoPhotos);
  if (draft.title.trim().length < 3) {
    messages.add(s.createProductWarnTitleShort);
  }
  if (draft.categoryId == null || draft.categoryId!.isEmpty) {
    messages.add(s.createProductWarnNoCategory);
  }
  if (draft.price == null || draft.price! <= 0) {
    messages.add(s.createProductWarnNoPrice);
  }
  if (draft.currency.isEmpty) messages.add(s.createProductWarnNoCurrency);
  return messages;
}
