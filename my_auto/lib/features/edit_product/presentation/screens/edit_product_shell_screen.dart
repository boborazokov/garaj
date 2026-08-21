import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Text(
                          'Edit your listing in sections. Changes publish when you tap save.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _section(colors, title: 'Photos', child: const PhotosStep(compact: true))),
                    SliverToBoxAdapter(
                      child: _section(colors, title: 'Basic info', subtitle: 'Title, description & condition',
                          child: const ProductInfoStep(compact: true)),
                    ),
                    SliverToBoxAdapter(
                      child: _section(colors, title: 'Vehicle & category', subtitle: 'Helps filtering & search',
                          child: const VehicleStep(compact: true)),
                    ),
                    SliverToBoxAdapter(child: _section(colors, title: 'Price & delivery', child: const PriceStep(compact: true))),
                    SliverToBoxAdapter(
                      child: _placeholderSection(
                        context,
                        title: 'Contact options',
                        body: 'Phone / Telegram / WhatsApp toggles tie into your seller profile rollout.',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _placeholderSection(
                        context,
                        title: 'Promotion',
                        body: 'Boosts and featured placements will appear here.',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _section(
                        colors,
                        title: 'Preview',
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
              bottomNavigationBar: BottomSafeButton(
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: state.isPublishing
                            ? null
                            : () => _bloc.add(const CreateProductPublishRequested()),
                        child: state.isPublishing
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                  ],
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: colors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.rL,
          side: BorderSide(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.layoutList, color: colors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderSection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: colors.surfaceMuted.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(body, style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
