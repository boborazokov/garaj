import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/category_lucide_icon.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/features/workshop/data/models/workshop_category.dart';

/// Workshop service categories: icon on top, localized name below.
class WorkshopServicesGrid extends StatelessWidget {
  const WorkshopServicesGrid({
    super.key,
    required this.categories,
    this.crossAxisCount = 4,
  });

  final List<WorkshopCategory> categories;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final lang = categoryLanguageCode(context);
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 600 ? 5 : crossAxisCount;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: 0.88,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final c = categories[index];
            return _ServiceTile(
              title: c.names.compactForLocale(lang, maxChars: 22),
              icon: categoryLucideIcon(c.icon) ?? LucideIcons.wrench,
              accent: _colorFromHex(c.color) ?? colors.primary,
              colors: colors,
            );
          },
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.title,
    required this.icon,
    required this.accent,
    required this.colors,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: AppRadius.rM,
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, size: 22, color: accent),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.15,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.trim().isEmpty) return null;
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final value = int.tryParse(h, radix: 16);
  if (value == null) return null;
  return Color(value);
}
