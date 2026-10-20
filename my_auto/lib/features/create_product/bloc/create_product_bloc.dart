import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/create_product/data/datasources/draft_storage.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/features/create_product/domain/repositories/create_product_repository.dart';
import 'package:my_auto/features/create_product/domain/create_product_messages.dart';
import 'package:my_auto/features/create_product/domain/services/smart_listing_service.dart';

part 'create_product_event.dart';
part 'create_product_state.dart';

class CreateProductBloc extends Bloc<CreateProductEvent, CreateProductState> {
  CreateProductBloc({
    required CreateProductRepository repository,
    DraftStorage? draftStorage,
    SmartListingService? smartListing,
  })  : _repository = repository,
        _draftStorage = draftStorage ?? DraftStorage(),
        _smart = smartListing ?? SmartListingService(),
        super(const CreateProductState()) {
    on<CreateProductStarted>(_onStarted);
    on<CreateProductStepChanged>(_onStepChanged);
    on<CreateProductNextStep>(_onNext);
    on<CreateProductPreviousStep>(_onPrevious);
    on<CreateProductPhotosPicked>(_onPhotosPicked);
    on<CreateProductPhotoRemoved>(_onPhotoRemoved);
    on<CreateProductPhotosReordered>(_onPhotosReordered);
    on<CreateProductVehicleUpdated>(_onVehicle);
    on<CreateProductRegionChanged>(_onRegion);
    on<CreateProductTitleChanged>(_onTitle);
    on<CreateProductDescriptionChanged>(_onDescription);
    on<CreateProductConditionChanged>(_onCondition);
    on<CreateProductPriceChanged>(_onPrice);
    on<CreateProductCurrencyChanged>(_onCurrency);
    on<CreateProductNegotiableChanged>(_onNegotiable);
    on<CreateProductDeliveryChanged>(_onDelivery);
    on<CreateProductPublishRequested>(_onPublish);
    on<CreateProductDraftAutosave>(_onAutosave);

    _autosaveTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => add(const CreateProductDraftAutosave()),
    );
  }

  final CreateProductRepository _repository;
  final DraftStorage _draftStorage;
  final SmartListingService _smart;
  Timer? _autosaveTimer;
  final List<String> _recentTitles = [];

  static const _stepOrder = CreateProductStep.values;

  /// Models for [brandId] from the tree, or `getCategories(parentId)` fallback.
  Future<List<CategoryNode>> loadModelsForBrand(String brandId) async {
    final fromTree = state.categoryTree.modelsForBrand(brandId);
    if (fromTree.isNotEmpty) return fromTree;
    return _repository.fetchModelsForBrand(brandId);
  }

  Future<void> _onStarted(
    CreateProductStarted event,
    Emitter<CreateProductState> emit,
  ) async {
    emit(state.copyWith(status: CreateProductStatus.loading, clearError: true));

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final offline = connectivity.every(
        (r) => r == ConnectivityResult.none,
      );

      CreateProductDraft draft;
      if (event.existingPart != null) {
        draft = _repository.draftFromPart(event.existingPart!);
      } else if (event.useSavedDraft) {
        draft = await _draftStorage.loadDraft() ?? const CreateProductDraft();
        final validPhotos = draft.photos.where((p) {
          if (p.isNetwork) return true;
          return p.file != null && p.file!.existsSync();
        }).toList();
        draft = draft.copyWith(photos: validPhotos);
      } else {
        draft = const CreateProductDraft();
      }

      final tree = await _repository.fetchCategoryTree();
      final parts = await _repository.fetchPartCategories();
      final recent = await _draftStorage.loadRecentVehicles();

      var smartDraft = _applySmart(draft, parts);
      smartDraft = _ensureCategory(smartDraft, parts);

      emit(
        state.copyWith(
          status: CreateProductStatus.ready,
          draft: smartDraft,
          categoryTree: tree,
          partCategories: parts,
          recentVehicles: recent,
          isOffline: offline,
          languageCode: event.languageCode,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateProductStatus.ready,
          draft: const CreateProductDraft(),
          errorMessage: _humanizeError(e),
        ),
      );
    }
  }

  void _onStepChanged(
    CreateProductStepChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(step: event.step)));
  }

  void _onNext(CreateProductNextStep event, Emitter<CreateProductState> emit) {
    final idx = _stepOrder.indexOf(state.draft.step);
    if (idx < 0 || idx >= _stepOrder.length - 1) return;
    emit(state.copyWith(draft: state.draft.copyWith(step: _stepOrder[idx + 1])));
  }

  void _onPrevious(
    CreateProductPreviousStep event,
    Emitter<CreateProductState> emit,
  ) {
    final idx = _stepOrder.indexOf(state.draft.step);
    if (idx <= 0) return;
    emit(state.copyWith(draft: state.draft.copyWith(step: _stepOrder[idx - 1])));
  }

  Future<void> _onPhotosPicked(
    CreateProductPhotosPicked event,
    Emitter<CreateProductState> emit,
  ) async {
    final compressed = <ProductPhoto>[];
    for (final file in event.files) {
      if (state.draft.photos.length + compressed.length >= 8) break;
      compressed.add(
        ProductPhoto(
          id: '${DateTime.now().microsecondsSinceEpoch}_${file.path}',
          file: file,
        ),
      );
    }
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          photos: [...state.draft.photos, ...compressed],
        ),
      ),
    );
  }

  void _onPhotoRemoved(
    CreateProductPhotoRemoved event,
    Emitter<CreateProductState> emit,
  ) {
    final photos = [...state.draft.photos]
      ..removeWhere((p) => p.id == event.photoId);
    emit(state.copyWith(draft: state.draft.copyWith(photos: photos)));
  }

  void _onPhotosReordered(
    CreateProductPhotosReordered event,
    Emitter<CreateProductState> emit,
  ) {
    final photos = [...state.draft.photos];
    var newIndex = event.newIndex;
    final oldIndex = event.oldIndex;
    if (oldIndex < 0 || oldIndex >= photos.length) return;
    if (newIndex < 0) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex < 0 || newIndex >= photos.length) return;
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    emit(state.copyWith(draft: state.draft.copyWith(photos: photos)));
  }

  void _onVehicle(
    CreateProductVehicleUpdated event,
    Emitter<CreateProductState> emit,
  ) {
    final draft = state.draft.copyWith(vehicle: event.vehicle);
    emit(
      state.copyWith(draft: draft),
    );
    unawaited(_draftStorage.pushRecentVehicle(event.vehicle));
  }

  void _onRegion(
    CreateProductRegionChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(region: event.region)));
  }

  void _onTitle(CreateProductTitleChanged event, Emitter<CreateProductState> emit) {
    final draft = state.draft.copyWith(title: event.title);
    emit(
      state.copyWith(
        draft: draft.copyWith(tags: _smart.autoTags(draft)),
        duplicateWarning: _smart.duplicateWarning(draft, _recentTitles) != null
            ? CreateProductErrorCodes.duplicateTitle
            : null,
      ),
    );
  }

  void _onDescription(
    CreateProductDescriptionChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(description: event.description)));
  }

  void _onCondition(
    CreateProductConditionChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(condition: event.condition)));
  }

  void _onPrice(CreateProductPriceChanged event, Emitter<CreateProductState> emit) {
    emit(state.copyWith(draft: state.draft.copyWith(price: event.price)));
  }

  void _onCurrency(
    CreateProductCurrencyChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(currency: event.currency)));
  }

  void _onNegotiable(
    CreateProductNegotiableChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(negotiable: event.negotiable)));
  }

  void _onDelivery(
    CreateProductDeliveryChanged event,
    Emitter<CreateProductState> emit,
  ) {
    emit(state.copyWith(draft: state.draft.copyWith(delivery: event.delivery)));
  }

  Future<void> _onPublish(
    CreateProductPublishRequested event,
    Emitter<CreateProductState> emit,
  ) async {
    var draft = _ensureCategory(state.draft, state.partCategories);

    if (!draft.canPublish) {
      final msg = createProductValidationErrorCodes(draft).join('\n');
      emit(
        state.copyWith(
          status: CreateProductStatus.failure,
          errorMessage: msg,
        ),
      );
      return;
    }

    if (state.isOffline) {
      await _draftStorage.saveDraft(draft);
      emit(
        state.copyWith(
          status: CreateProductStatus.failure,
          errorMessage: CreateProductErrorCodes.offlinePublish,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CreateProductStatus.publishing,
        draft: draft,
        uploadProgress: 0,
        clearError: true,
      ),
    );

    try {
      final localFiles = draft.photos
          .where((p) => p.file != null && p.file!.existsSync())
          .map((p) => p.file!)
          .toList();

      String partId = draft.editingPartId ?? '';
      if (partId.isEmpty) {
        partId = await _repository.createPart(draft);
      } else {
        await _repository.updatePart(partId, draft);
      }

      if (localFiles.isNotEmpty) {
        await _repository.uploadImages(
          partId: partId,
          files: localFiles,
          onProgress: (p) {
            if (!isClosed) {
              emit(
                state.copyWith(
                  status: CreateProductStatus.publishing,
                  uploadProgress: p,
                ),
              );
            }
          },
        );
      }

      _recentTitles.add(draft.title.trim());
      await _draftStorage.clearDraft();
      await _draftStorage.pushRecentVehicle(draft.vehicle);

      emit(
        state.copyWith(
          status: CreateProductStatus.success,
          uploadProgress: 1,
        ),
      );
    } catch (e) {
      await _draftStorage.saveDraft(draft);
      emit(
        state.copyWith(
          status: CreateProductStatus.failure,
          errorMessage: _humanizeError(e),
        ),
      );
    }
  }

  CreateProductDraft _ensureCategory(
    CreateProductDraft draft,
    List<CategoryNode> parts,
  ) {
    if (draft.categoryId != null && draft.categoryId!.isNotEmpty) {
      return draft;
    }
    if (parts.isEmpty) return draft;
    final cat = parts.first;
    return draft.copyWith(
      vehicle: draft.vehicle.copyWith(
        partCategoryId: cat.id,
        partCategoryName: cat.localizedName(state.languageCode),
      ),
    );
  }

  String _humanizeError(Object e) {
    final raw = e.toString();
    if (raw.contains('UNAUTHENTICATED') ||
        raw.contains('Unauthorized') ||
        raw.contains('401')) {
      return CreateProductErrorCodes.signInRequired;
    }
    if (raw.contains('SocketException') ||
        raw.contains('NetworkException') ||
        raw.contains('Connection refused')) {
      return CreateProductErrorCodes.serverUnreachable;
    }
    if (raw.contains('category')) {
      return CreateProductErrorCodes.categoryRequired;
    }
    return raw.length > 180 ? '${raw.substring(0, 180)}…' : raw;
  }

  Future<void> _onAutosave(
    CreateProductDraftAutosave event,
    Emitter<CreateProductState> emit,
  ) async {
    if (state.status == CreateProductStatus.publishing) return;
    if (!state.draft.hasMeaningfulProgress) return;
    await _draftStorage.saveDraft(state.draft);
    emit(state.copyWith(draftSavedAt: DateTime.now()));
  }

  CreateProductDraft _applySmart(
    CreateProductDraft draft,
    List<CategoryNode> parts,
  ) {
    final hint = _smart.recommendedCategoryName(draft);
    final match = _smart.matchPartCategory(parts, hint);
    if (match != null && draft.vehicle.partCategoryId == null) {
      return draft.copyWith(
        vehicle: draft.vehicle.copyWith(
          partCategoryId: match.id,
          partCategoryName: match.localizedName(state.languageCode),
        ),
        tags: _smart.autoTags(draft),
      );
    }
    return draft.copyWith(tags: _smart.autoTags(draft));
  }

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }
}
