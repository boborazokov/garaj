part of 'create_product_bloc.dart';

sealed class CreateProductEvent extends Equatable {
  const CreateProductEvent();

  @override
  List<Object?> get props => [];
}

final class CreateProductStarted extends CreateProductEvent {
  const CreateProductStarted({
    this.existingPart,
    this.useSavedDraft = true,
    this.languageCode = 'ru',
  });

  final Part? existingPart;

  /// When false, starts with an empty form (saved draft is ignored).
  final bool useSavedDraft;

  final String languageCode;

  @override
  List<Object?> get props => [existingPart, useSavedDraft, languageCode];
}

final class CreateProductStepChanged extends CreateProductEvent {
  const CreateProductStepChanged(this.step);
  final CreateProductStep step;
  @override
  List<Object?> get props => [step];
}

final class CreateProductNextStep extends CreateProductEvent {
  const CreateProductNextStep();
}

final class CreateProductPreviousStep extends CreateProductEvent {
  const CreateProductPreviousStep();
}

final class CreateProductPhotosPicked extends CreateProductEvent {
  const CreateProductPhotosPicked(this.files);
  final List<File> files;
  @override
  List<Object?> get props => [files];
}

final class CreateProductPhotoRemoved extends CreateProductEvent {
  const CreateProductPhotoRemoved(this.photoId);
  final String photoId;
  @override
  List<Object?> get props => [photoId];
}

final class CreateProductPhotosReordered extends CreateProductEvent {
  const CreateProductPhotosReordered(this.oldIndex, this.newIndex);
  final int oldIndex;
  final int newIndex;
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

final class CreateProductVehicleUpdated extends CreateProductEvent {
  const CreateProductVehicleUpdated(this.vehicle);
  final VehicleSelection vehicle;
  @override
  List<Object?> get props => [vehicle];
}

final class CreateProductRegionChanged extends CreateProductEvent {
  const CreateProductRegionChanged(this.region);
  final String region;
  @override
  List<Object?> get props => [region];
}

final class CreateProductTitleChanged extends CreateProductEvent {
  const CreateProductTitleChanged(this.title);
  final String title;
  @override
  List<Object?> get props => [title];
}

final class CreateProductDescriptionChanged extends CreateProductEvent {
  const CreateProductDescriptionChanged(this.description);
  final String description;
  @override
  List<Object?> get props => [description];
}

final class CreateProductConditionChanged extends CreateProductEvent {
  const CreateProductConditionChanged(this.condition);
  final ProductCondition condition;
  @override
  List<Object?> get props => [condition];
}

final class CreateProductPriceChanged extends CreateProductEvent {
  const CreateProductPriceChanged(this.price);
  final int? price;
  @override
  List<Object?> get props => [price];
}

final class CreateProductCurrencyChanged extends CreateProductEvent {
  const CreateProductCurrencyChanged(this.currency);
  final String currency;
  @override
  List<Object?> get props => [currency];
}

final class CreateProductNegotiableChanged extends CreateProductEvent {
  const CreateProductNegotiableChanged(this.negotiable);
  final bool negotiable;
  @override
  List<Object?> get props => [negotiable];
}

final class CreateProductDeliveryChanged extends CreateProductEvent {
  const CreateProductDeliveryChanged(this.delivery);
  final DeliveryOption delivery;
  @override
  List<Object?> get props => [delivery];
}

final class CreateProductPublishRequested extends CreateProductEvent {
  const CreateProductPublishRequested();
}

final class CreateProductDraftAutosave extends CreateProductEvent {
  const CreateProductDraftAutosave();
}
