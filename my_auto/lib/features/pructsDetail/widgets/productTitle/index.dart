import 'package:flutter/material.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/promotion/presentation/promotion_plan_badge.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';
import 'package:provider/provider.dart';

/// Price-first header for product detail.
class ProductTitle extends StatelessWidget {
  final String name;
  final int price;
  final String currency;
  final CategoryCar? category;
  final CategoryCar? brand;
  final CategoryCar? carModel;
  final DateTime createdDate;
  final String location;
  final String? region;
  final bool? condition;
  final bool negotiable;
  final bool isPromoted;
  final String? promotionPlan;
  final bool showPrice;
  final int viewsCount;

  const ProductTitle({
    super.key,
    required this.name,
    required this.price,
    required this.currency,
    required this.createdDate,
    required this.location,
    this.category,
    this.brand,
    this.carModel,
    this.region,
    this.condition,
    this.negotiable = false,
    this.isPromoted = false,
    this.promotionPlan,
    this.showPrice = true,
    this.viewsCount = 0,
  });

  static bool _hasVehicleName(String value) {
    final text = value.trim();
    if (text.isEmpty) return false;
    return RegExp(r'[^\s\-–—._·•]').hasMatch(text);
  }

  String _formatPrice() {
    final raw = price.toString();
    final parts = <String>[];
    for (var i = raw.length; i > 0; i -= 3) {
      final start = i - 3 < 0 ? 0 : i - 3;
      parts.add(raw.substring(start, i));
    }
    return '${parts.reversed.join(' ')} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final lang = context.watch<LocaleNotifier>().locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final vehicle = [
      if (brand != null) brand!.localizedName(lang),
      if (carModel != null) carModel!.localizedName(lang),
    ].where(_hasVehicleName).join(' · ');
    final categoryName = category?.localizedName(lang).trim() ?? '';
    final place = regionOnlyLabel(location);

    return SliverToBoxAdapter(
      child: ProductSection(
        margin: const EdgeInsets.fromLTRB(
          MarketUi.spacingMD,
          MarketUi.sectionGap,
          MarketUi.spacingMD,
          0,
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showPrice ? _formatPrice() : s.negotiable,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.5,
                height: 1.05,
              ),
            ),
            if (negotiable && showPrice) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                s.negotiable,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                height: 1.25,
                color: colors.textPrimary,
              ),
            ),
            if (vehicle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                vehicle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                if (isPromoted)
                  PromotionPlanBadge(plan: promotionPlan, dense: false),
                if (condition != null)
                  _MetaChip(
                    label: condition! ? s.newPart : s.used,
                    foreground: colors.textSecondary,
                    background: colors.surfaceMuted,
                  ),
                if (categoryName.isNotEmpty)
                  _MetaChip(
                    label: categoryName,
                    foreground: colors.textSecondary,
                    background: colors.surfaceMuted,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: CardDateRegion(
                    createdAt: createdDate,
                    region: region,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$viewsCount ${s.views}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (place.isNotEmpty &&
                place != regionOnlyLabel(region)) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                location.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.foreground,
    required this.background,
    this.borderColor,
    this.showBayDot = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;
  final bool showBayDot;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.rS,
        border: Border.all(color: borderColor ?? colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBayDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
