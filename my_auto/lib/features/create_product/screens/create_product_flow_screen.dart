import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/create_product_di.dart';
import 'package:my_auto/features/create_product/data/datasources/draft_storage.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/features/create_product/widgets/photos_step.dart';
import 'package:my_auto/features/create_product/widgets/preview_step.dart';
import 'package:my_auto/features/create_product/widgets/price_step.dart';
import 'package:my_auto/features/create_product/widgets/product_info_step.dart';
import 'package:my_auto/features/create_product/widgets/step_progress_header.dart';
import 'package:my_auto/features/create_product/widgets/sticky_continue_bar.dart';
import 'package:my_auto/features/create_product/widgets/unfinished_listing_sheet.dart';
import 'package:my_auto/features/create_product/domain/create_product_messages.dart';
import 'package:my_auto/features/create_product/widgets/vehicle_step.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/generated/l10n.dart';

class CreateProductFlowScreen extends StatefulWidget {
  const CreateProductFlowScreen({super.key, this.existingPart});

  final Part? existingPart;

  @override
  State<CreateProductFlowScreen> createState() =>
      _CreateProductFlowScreenState();
}

class _CreateProductFlowScreenState extends State<CreateProductFlowScreen> {
  late final CreateProductBloc _bloc;
  final _draftStorage = DraftStorage();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bloc = createProductBloc(repo: createProductRepository());
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (widget.existingPart != null) {
      _bloc.add(CreateProductStarted(
        existingPart: widget.existingPart,
        languageCode: categoryLanguageCode(context),
      ));
      if (mounted) setState(() => _initialized = true);
      return;
    }

    final saved = await _draftStorage.loadDraft();
    var useSavedDraft = false;

    if (saved != null && saved.hasMeaningfulProgress && mounted) {
      final choice = await UnfinishedListingSheet.showResumePrompt(
        context,
        saved,
      );
      if (!mounted) return;
      if (choice == null) {
        context.pop();
        return;
      }
      useSavedDraft = choice == UnfinishedListingChoice.continueDraft;
      if (choice == UnfinishedListingChoice.startNew) {
        await _draftStorage.clearDraft();
      }
    }

    _bloc.add(CreateProductStarted(
      useSavedDraft: useSavedDraft,
      languageCode: categoryLanguageCode(context),
    ));
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          title: Text(
            widget.existingPart != null
                ? S.of(context).edit
                : S.of(context).addProduct,
          ),
        ),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return BlocProvider.value(
      value: _bloc,
      child: _CreateProductFlowView(existingPart: widget.existingPart),
    );
  }
}

class _CreateProductFlowView extends StatelessWidget {
  const _CreateProductFlowView({required this.existingPart});

  final Part? existingPart;

  bool _canContinue(CreateProductState state) {
    final step = state.draft.step;
    switch (step) {
      case CreateProductStep.photos:
        return state.draft.hasPhotos;
      case CreateProductStep.vehicle:
        return state.draft.categoryId != null &&
            state.draft.region.trim().isNotEmpty;
      case CreateProductStep.info:
        return state.draft.title.trim().length >= 3;
      case CreateProductStep.price:
        return state.draft.price != null && state.draft.price! > 0;
      case CreateProductStep.preview:
        return state.draft.canPublish;
    }
  }

  String _continueLabel(BuildContext context, CreateProductState state) {
    final s = S.of(context);
    if (state.draft.step == CreateProductStep.preview) {
      return state.draft.editingPartId != null
          ? s.createProductUpdateListing
          : s.createProductPublishNow;
    }
    return s.createProductContinue;
  }

  bool _canLeave(CreateProductState state) =>
      existingPart != null || !state.isPublishing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<CreateProductBloc, CreateProductState>(
      listenWhen: (p, c) =>
          p.status != c.status || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        final s = S.of(context);
        if (state.status == CreateProductStatus.success) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.createProductPublishedSuccess)),
          );
          context.pop(true);
          return;
        }
        if (state.errorMessage != null &&
            state.status == CreateProductStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizeCreateProductError(s, state.errorMessage!),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      builder: (context, state) {
        final s = S.of(context);
        if (state.status == CreateProductStatus.loading ||
            state.status == CreateProductStatus.initial) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const AppSafeArea(
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }

        final bloc = context.read<CreateProductBloc>();
        final isEdit = state.draft.editingPartId != null;

        return PopScope(
          canPop: _canLeave(state) &&
              state.draft.step == CreateProductStep.photos,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (!_canLeave(state)) return;
            if (state.draft.step != CreateProductStep.photos) {
              bloc.add(const CreateProductPreviousStep());
            }
          },
          child: Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              title:
                  Text(isEdit ? S.of(context).edit : S.of(context).addProduct),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: !_canLeave(state)
                    ? null
                    : () {
                        if (state.draft.step == CreateProductStep.photos) {
                          context.pop();
                        } else {
                          bloc.add(const CreateProductPreviousStep());
                        }
                      },
              ),
            ),
            body: Column(
              children: [
                StepProgressHeader(
                  current: state.draft.step,
                  draftSavedAt: state.draftSavedAt,
                ),
                if (state.errorMessage != null &&
                    state.status == CreateProductStatus.ready &&
                    state.partCategories.isEmpty)
                  MaterialBanner(
                    content: Text(state.errorMessage!),
                    backgroundColor: colors.danger.withValues(alpha: 0.12),
                    actions: [
                      TextButton(
                        onPressed: () => bloc.add(
                              CreateProductStarted(
                                existingPart: existingPart,
                                languageCode: categoryLanguageCode(context),
                              ),
                            ),
                        child: Text(s.createProductRetry),
                      ),
                    ],
                  ),
                if (state.isOffline)
                  MaterialBanner(
                    content: Text(s.createProductOfflineBanner),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: Text(s.createProductOk),
                      ),
                    ],
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _StepBody(
                      key: ValueKey(state.draft.step),
                      step: state.draft.step,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: StickyContinueBar(
              label: _continueLabel(context, state),
              enabled: _canContinue(state),
              isLoading: state.isPublishing,
              secondaryLabel: state.draft.step != CreateProductStep.photos
                  ? s.back
                  : null,
              onSecondary: state.draft.step != CreateProductStep.photos
                  ? () => bloc.add(const CreateProductPreviousStep())
                  : null,
              onPressed: () {
                if (state.draft.step == CreateProductStep.preview) {
                  bloc.add(const CreateProductPublishRequested());
                } else {
                  bloc.add(const CreateProductNextStep());
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({super.key, required this.step});

  final CreateProductStep step;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateProductBloc>();

    switch (step) {
      case CreateProductStep.photos:
        return const PhotosStep();
      case CreateProductStep.vehicle:
        return const VehicleStep();
      case CreateProductStep.info:
        return const ProductInfoStep();
      case CreateProductStep.price:
        return const PriceStep();
      case CreateProductStep.preview:
        return PreviewStep(
          onEditStep: (s) => bloc.add(CreateProductStepChanged(s)),
        );
    }
  }
}
