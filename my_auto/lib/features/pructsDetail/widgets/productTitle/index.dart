import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/place_label.dart';
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

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showPrice ? _formatPrice() : s.negotiable,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.primary,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
            if (negotiable && showPrice) ...[
              const SizedBox(height: 4),
              Text(
                s.negotiable,
                style: TextStyle(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1.25,
                color: colors.textPrimary,
              ),
            ),
            if (vehicle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                vehicle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isPromoted)
                  _MetaChip(
                    icon: LucideIcons.flame,
                    label: s.promotedBadge,
                    foreground: colors.onPrimary,
                    background: colors.primary,
                  ),
                if (condition != null)
                  _MetaChip(
                    icon: condition!
                        ? LucideIcons.sparkles
                        : LucideIcons.package,
                    label: condition! ? s.newPart : s.used,
                    foreground: Colors.white,
                    background: condition! ? colors.success : colors.warning,
                  ),
                if (categoryName.isNotEmpty)
                  _MetaChip(
                    icon: LucideIcons.tag,
                    label: categoryName,
                    foreground: colors.primary,
                    background: colors.primary.withValues(alpha: 0.12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            CardDateRegion(
              createdAt: createdDate,
              region: region,
              fontSize: 13,
            ),
            const SizedBox(height: 6),
            Text(
              '$viewsCount ${s.views}',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (regionOnlyLabel(location).isNotEmpty &&
                regionOnlyLabel(location) != regionOnlyLabel(region)) ...[
              const SizedBox(height: 4),
              Text(
                location.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
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
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
