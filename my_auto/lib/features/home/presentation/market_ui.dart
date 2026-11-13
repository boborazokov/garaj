import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

/// Shared marketplace surface tokens — radius 18–24, spacing 8 / 12 / 16 / 20.
abstract final class MarketUi {
  static const double spacingXS = AppSpacing.xs;
  static const double spacingSM = AppSpacing.m;
  static const double spacingMD = AppSpacing.screenPadding;
  static const double spacingLG = AppSpacing.xl;
  static const double spacingXL = AppSpacing.xxl;

  /// Gap between stacked product detail sections.
  static const double sectionGap = AppSpacing.m;

  static BorderRadius get cardRadius => BorderRadius.circular(22);

  /// Quiet depth: hairlines carry the card on light; whisper shadow on dark.
  static List<BoxShadow> softElev(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return const [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: .22),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static BoxDecoration card(BuildContext context, AppColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: cardRadius,
      border: Border.all(color: colors.border.withValues(alpha: 0.9)),
      boxShadow: softElev(context),
    );
  }

  /// Inset product section (PDP / edit cards) on muted page background.
  static BoxDecoration productSection(BuildContext context, AppColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: cardRadius,
      border: Border.all(color: colors.border),
      boxShadow: softElev(context),
    );
  }

  /// Floating thumb-zone dock for Call / Chat / Continue / Save.
  static BoxDecoration actionDock(BuildContext context, AppColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: cardRadius,
      border: Border.all(color: colors.border),
      boxShadow: AppShadows.floating(context),
    );
  }
}

/// Rounded inset section used across product detail and edit shells.
class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      MarketUi.spacingMD,
      MarketUi.spacingMD,
      MarketUi.spacingMD,
      MarketUi.spacingLG,
    ),
    this.margin = const EdgeInsets.fromLTRB(
      MarketUi.spacingMD,
      MarketUi.sectionGap,
      MarketUi.spacingMD,
      0,
    ),
    this.title,
    this.subtitle,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: MarketUi.productSection(context, colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: colors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

/// Tappable marketplace card shell — border, radius, optional ink.
class MarketCardShell extends StatelessWidget {
  const MarketCardShell({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
    /// Cheaper paint for feed tiles (no Ink decoration / shadow path).
    this.lite = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final bool lite;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    final Widget material;
    if (lite) {
      material = Material(
        color: colors.surface,
        borderRadius: MarketUi.cardRadius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: MarketUi.cardRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: MarketUi.cardRadius,
              border: Border.all(color: colors.border.withValues(alpha: 0.9)),
            ),
            child: content,
          ),
        ),
      );
    } else {
      material = Material(
        color: colors.surface,
        borderRadius: MarketUi.cardRadius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: MarketUi.cardRadius,
          child: Ink(
            decoration: MarketUi.card(context, colors),
            child: content,
          ),
        ),
      );
    }

    if (margin == null) return material;
    return Padding(padding: margin!, child: material);
  }
}

/// Small status / promo chip used across listing cards.
class MarketBadgeChip extends StatelessWidget {
  const MarketBadgeChip({
    super.key,
    required this.label,
    this.emphasized = false,
    this.dense = false,
  });

  final String label;
  final bool emphasized;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 8,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: emphasized
            ? colors.primary.withValues(alpha: 0.12)
            : colors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(
          color: emphasized
              ? colors.primary.withValues(alpha: 0.28)
              : colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emphasized) ...[
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
              color: emphasized ? colors.primary : colors.textPrimary,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight section title row (minimal text, optional action).
class MarketSectionTitle extends StatelessWidget {
  const MarketSectionTitle({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailing,
    this.leading,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MarketUi.spacingMD,
        12,
        MarketUi.spacingMD,
        8,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: colors.textPrimary,
              ),
            ),
          ),
          if (trailingLabel != null && onTrailing != null)
            TextButton(
              onPressed: onTrailing,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(trailingLabel!),
            ),
        ],
      ),
    );
  }
}
