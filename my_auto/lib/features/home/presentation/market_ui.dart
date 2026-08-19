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

  static BorderRadius get cardRadius => BorderRadius.circular(20);

  /// Single soft elevation (minimal shadow clutter).
  static List<BoxShadow> softElev(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.black.withValues(alpha: .35) : const Color(0x120B0F14);
    return [
      BoxShadow(
        color: c,
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static BoxDecoration card(BuildContext context, AppColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: cardRadius,
      boxShadow: softElev(context),
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
        MarketUi.spacingMD,
        MarketUi.spacingMD,
        MarketUi.spacingSM,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
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
