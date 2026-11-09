import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/create_product_di.dart';
import 'package:my_auto/features/create_product/widgets/photos_step.dart';
import 'package:my_auto/features/create_product/widgets/preview_step.dart';
import 'package:my_auto/features/create_product/widgets/price_step.dart';
import 'package:my_auto/features/create_product/widgets/product_info_step.dart';
import 'package:my_auto/features/create_product/widgets/vehicle_step.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/generated/l10n.dart';

/// Section-based editor for an existing listing. Reuses [CreateProductBloc]
/// validation, autosave ticks, REST image upload and publish pipeline.
///
/// Promotion / contacts / richer attributes are scaffolded via placeholder
/// cards until backend fields exist (see backlog in project brief).
class EditProductShellScreen extends StatefulWidget {
  const EditProductShellScreen({super.key, required this.existingPart});

  final Part existingPart;

  @override
  State<EditProductShellScreen> createState() => _EditProductShellScreenState();
}

class _EditProductShellScreenState extends State<EditProductShellScreen> {
  late final CreateProductBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = createProductBloc(repo: createProductRepository());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bloc.add(CreateProductStarted(
        existingPart: widget.existingPart,
        languageCode: categoryLanguageCode(context),
      ));
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<CreateProductBloc, CreateProductState>(
        listenWhen: (p, c) =>
            p.status != c.status || p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.status == CreateProductStatus.success) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).done)),
            );
            context.pop(true);
          } else if (state.errorMessage != null &&
              state.status == CreateProductStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), duration: const Duration(seconds: 5)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CreateProductStatus.loading ||
              state.status == CreateProductStatus.initial) {
            return Scaffold(
              backgroundColor: colors.background,
              body: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          return PopScope(
            canPop: !_bloc.state.isPublishing,
            child: Scaffold(
              backgroundColor: colors.background,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(S.of(context).edit),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _bloc.state.isPublishing ? null : () => context.pop(),
                ),
              ),
              body: KeyboardSafeView(
                child: AppSafeArea(
                top: false,
                bottom: false,
                child: CustomScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          MarketUi.spacingMD,
                          AppSpacing.s,
                          MarketUi.spacingMD,
                          AppSpacing.s,
                        ),
                        child: Text(
                          S.of(context).createProductPreviewSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _section(
                        colors,
                        title: S.of(context).photos,
                        child: const PhotosStep(compact: true),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _section(
                        colors,
                        title: S.of(context).createProductStepInfo,
                        subtitle: S.of(context).description,
                        child: const ProductInfoStep(compact: true),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _section(
                        colors,
                        title: S.of(context).createProductStepVehicle,
                        child: const VehicleStep(compact: true),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _section(
                        colors,
                        title: S.of(context).createProductStepPrice,
                        child: const PriceStep(compact: true),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _section(
                        colors,
                        title: S.of(context).createProductStepPreview,
                        child: PreviewStep(
                          compact: true,
                          onEditStep: (_) {},
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 112)),
                  ],
                ),
              ),
              ),
              bottomNavigationBar: Material(
                color: colors.background,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    MarketUi.spacingMD,
                    AppSpacing.s,
                    MarketUi.spacingMD,
                    stickyBottomPadding(context, keyboardExtra: 8, homeExtra: 12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: MarketUi.actionDock(context, colors),
                    child: FilledButton(
                      onPressed: state.isPublishing
                          ? null
                          : () => _bloc.add(
                                const CreateProductPublishRequested(),
                              ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.rM,
                        ),
                      ),
                      child: state.isPublishing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(S.of(context).save),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(
    AppColors colors, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return ProductSection(
      title: title,
      subtitle: subtitle,
      child: child,
    );
  }
}
