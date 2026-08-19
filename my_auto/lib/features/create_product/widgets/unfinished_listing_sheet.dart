import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/app_network_image.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/generated/l10n.dart';

enum UnfinishedListingChoice { continueDraft, startNew }

class UnfinishedListingSheet {
  static String stepLabel(BuildContext context, CreateProductStep step) {
    final s = S.of(context);
    switch (step) {
      case CreateProductStep.photos:
        return s.createProductStepPhotos;
      case CreateProductStep.vehicle:
        return s.createProductStepVehicle;
      case CreateProductStep.info:
        return s.createProductStepInfo;
      case CreateProductStep.price:
        return s.createProductStepPrice;
      case CreateProductStep.preview:
        return s.createProductStepPreview;
    }
  }

  /// Shown when opening create flow and a saved draft exists.
  static Future<UnfinishedListingChoice?> showResumePrompt(
    BuildContext context,
    CreateProductDraft draft,
  ) {
    final s = S.of(context);
    return showModalBottomSheet<UnfinishedListingChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _SheetBody(
        title: s.createProductUnfinishedTitle,
        hint: s.createProductUnfinishedHint,
        draft: draft,
        primaryLabel: s.createProductContinueDraft,
        secondaryLabel: s.createProductStartNew,
        onPrimary: () =>
            Navigator.pop(ctx, UnfinishedListingChoice.continueDraft),
        onSecondary: () => Navigator.pop(ctx, UnfinishedListingChoice.startNew),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.title,
    required this.hint,
    required this.draft,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String title;
  final String hint;
  final CreateProductDraft draft;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        stickyBottomPadding(context, homeExtra: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          _DraftListTile(draft: draft),
          const SizedBox(height: 20),
          FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
        ],
      ),
    );
  }
}

class _DraftListTile extends StatelessWidget {
  const _DraftListTile({required this.draft});

  final CreateProductDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final title = draft.title.trim().isEmpty
        ? s.createProductUntitled
        : draft.title.trim();
    final step = UnfinishedListingSheet.stepLabel(context, draft.step);
    final price = draft.price != null && draft.price! > 0
        ? '${draft.price} ${draft.currency}'
        : null;
    final updated = draft.updatedAt != null
        ? DateFormat.yMMMd().add_Hm().format(draft.updatedAt!.toLocal())
        : null;

    final subtitleParts = <String>[
      step,
      if (price != null) price,
      if (draft.photos.isNotEmpty) '${draft.photos.length} photo(s)',
      if (updated != null) updated,
    ];

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _DraftThumbnail(draft: draft),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitleParts.join(' · ')),
      ),
    );
  }
}

class _DraftThumbnail extends StatelessWidget {
  const _DraftThumbnail({required this.draft});

  final CreateProductDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cover = draft.coverPhoto;
    Widget child;

    if (cover?.networkUrl != null) {
      child = AppNetworkImage(
        path: cover!.networkUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      );
    } else if (cover?.file != null && cover!.file!.existsSync()) {
      child = Image.file(
        cover.file!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(colors),
      );
    } else {
      child = _placeholder(colors);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: 52, height: 52, child: child),
    );
  }

  Widget _placeholder(AppColors colors) {
    return ColoredBox(
      color: colors.border.withValues(alpha: 0.35),
      child: Icon(Icons.image_outlined, color: colors.textSecondary),
    );
  }
}
