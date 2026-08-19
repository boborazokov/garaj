part of 'create_product_bloc.dart';

enum CreateProductStatus {
  initial,
  loading,
  ready,
  publishing,
  success,
  failure,
}

class CreateProductState extends Equatable {
  const CreateProductState({
    this.status = CreateProductStatus.initial,
    this.draft = const CreateProductDraft(),
    this.categoryTree = const [],
    this.partCategories = const [],
    this.recentVehicles = const [],
    this.duplicateWarning,
    this.uploadProgress = 0,
    this.errorMessage,
    this.draftSavedAt,
    this.isOffline = false,
    this.languageCode = 'ru',
  });

  final CreateProductStatus status;
  final CreateProductDraft draft;
  final List<CategoryNode> categoryTree;
  final List<CategoryNode> partCategories;
  final List<VehicleSelection> recentVehicles;
  final String? duplicateWarning;
  final double uploadProgress;
  final String? errorMessage;
  final DateTime? draftSavedAt;
  final bool isOffline;
  final String languageCode;

  bool get isPublishing => status == CreateProductStatus.publishing;

  CreateProductState copyWith({
    CreateProductStatus? status,
    CreateProductDraft? draft,
    List<CategoryNode>? categoryTree,
    List<CategoryNode>? partCategories,
    List<VehicleSelection>? recentVehicles,
    String? duplicateWarning,
    double? uploadProgress,
    String? errorMessage,
    DateTime? draftSavedAt,
    bool? isOffline,
    String? languageCode,
    bool clearError = false,
    bool clearDuplicate = false,
  }) {
    return CreateProductState(
      status: status ?? this.status,
      draft: draft ?? this.draft,
      categoryTree: categoryTree ?? this.categoryTree,
      partCategories: partCategories ?? this.partCategories,
      recentVehicles: recentVehicles ?? this.recentVehicles,
      duplicateWarning:
          clearDuplicate ? null : duplicateWarning ?? this.duplicateWarning,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      draftSavedAt: draftSavedAt ?? this.draftSavedAt,
      isOffline: isOffline ?? this.isOffline,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        draft,
        categoryTree,
        partCategories,
        recentVehicles,
        duplicateWarning,
        uploadProgress,
        errorMessage,
        draftSavedAt,
        isOffline,
        languageCode,
      ];
}
