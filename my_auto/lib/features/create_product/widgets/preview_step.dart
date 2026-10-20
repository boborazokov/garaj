import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/app_network_image.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/domain/create_product_messages.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_auto/generated/l10n.dart';

class PreviewStep extends StatelessWidget {
  const PreviewStep({
    super.key,
    required this.onEditStep,
    this.compact = false,
  });

  final void Function(CreateProductStep step) onEditStep;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final state = context.watch<CreateProductBloc>().state;
    final draft = state.draft;
    final warnings = createProductValidationMessages(s, draft);

    return ListView(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(
        compact ? 0 : 16,
        compact ? 0 : 8,
        compact ? 0 : 16,
        compact ? 0 : 120,
      ),
      children: [
        Text(
          s.createProductPreviewTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          s.createProductPreviewSubtitle,
          style: TextStyle(color: colors.textMuted),
        ),
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(LucideIcons.alertCircle,
                      size: 16, color: colors.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _ListingPreviewCard(draft: draft),
        if (draft.editingPartId != null) ...[
          const SizedBox(height: 20),
          Text(
            s.edit,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _EditRow(
            icon: LucideIcons.image,
            label: s.createProductStepPhotos,
            onTap: () => onEditStep(CreateProductStep.photos),
          ),
          _EditRow(
            icon: LucideIcons.car,
            label: s.createProductStepVehicle,
            onTap: () => onEditStep(CreateProductStep.vehicle),
          ),
          _EditRow(
            icon: LucideIcons.fileText,
            label: s.createProductStepInfo,
            onTap: () => onEditStep(CreateProductStep.info),
          ),
          _EditRow(
            icon: LucideIcons.banknote,
            label: s.createProductStepPrice,
            onTap: () => onEditStep(CreateProductStep.price),
          ),
        ],
        if (state.isPublishing) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: state.uploadProgress),
          const SizedBox(height: 8),
          Text(
            s.createProductPublishing((state.uploadProgress * 100).toInt()),
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _ListingPreviewCard extends StatelessWidget {
  const _ListingPreviewCard({required this.draft});

  final CreateProductDraft draft;

  String _formatPrice(BuildContext context) {
    final price = draft.price ?? 0;
    if (price <= 0) return '—';
    final formatted = NumberFormat('#,###', 'ru').format(price).replaceAll(',', ' ');
    return '$formatted ${draft.currency}';
  }

  String? _vehicleLine() {
    final parts = <String>[
      if (draft.vehicle.brandName?.isNotEmpty == true) draft.vehicle.brandName!,
      if (draft.vehicle.modelName?.isNotEmpty == true) draft.vehicle.modelName!,
      if (draft.vehicle.partCategoryName?.isNotEmpty == true)
        draft.vehicle.partCategoryName!,
      if (draft.region.trim().isNotEmpty) draft.region.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String? _imagePath(ProductPhoto? photo) {
    if (photo == null) return null;
    if (photo.file != null && photo.file!.existsSync()) {
      return photo.file!.path;
    }
    if (photo.networkUrl != null && photo.networkUrl!.isNotEmpty) {
      return photo.networkUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final cover = draft.coverPhoto;
    final imagePath = _imagePath(cover);
    final isNew = draft.condition == ProductCondition.newPart;
    final conditionLabel = isNew ? s.newPart : s.used;
    final conditionColor = isNew ? colors.success : colors.warning;
    final title = draft.title.trim().isEmpty
        ? s.createProductUntitled
        : draft.title.trim();

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.rL,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: colors.surfaceMuted,
                    child: imagePath != null
                        ? AppNetworkImage(
                            path: imagePath,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            LucideIcons.imageOff,
                            size: 40,
                            color: colors.textMuted,
                          ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _PreviewBadge(
                      label: conditionLabel,
                      background: conditionColor,
                      foreground: isNew ? colors.onDark : Colors.white,
                    ),
                  ),
                  if (draft.negotiable)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _PreviewBadge(
                        label: s.negotiable,
                        background: colors.primary,
                        foreground: colors.onPrimary,
                        icon: LucideIcons.percent,
                      ),
                    ),
                  if (draft.photos.length > 1)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _PreviewBadge(
                        label: '${draft.photos.length}',
                        background: colors.onDark.withValues(alpha: 0.72),
                        foreground: Colors.white,
                        icon: LucideIcons.image,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPrice(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.truck, size: 13, color: colors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        getDeliveryStatus(draft.delivery.apiValue),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_vehicleLine() != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.car, size: 13, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _vehicleLine()!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(LucideIcons.pencil, size: 18, color: colors.textMuted),
      onTap: onTap,
    );
  }
}
