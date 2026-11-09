import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/generated/l10n.dart';

/// Self-promo slot when no paid campaign is active for [surface].
/// Tap opens the advertise / tariffs screen.
class AdPlaceholderBanner extends StatelessWidget {
  const AdPlaceholderBanner({
    super.key,
    required this.surface,
    required this.height,
    required this.margin,
    required this.borderRadius,
  });

  final AdSurface surface;
  final double height;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: margin,
      child: Material(
        color: colors.surface,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: () => context.push(
            RoutesName.advertise,
            extra: surface.api,
          ),
          borderRadius: borderRadius,
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: colors.border),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surfaceMuted.withValues(alpha: 0.55),
                  colors.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.rM,
                    ),
                    child: Icon(
                      LucideIcons.megaphone,
                      size: 22,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            s.adPlaceholderBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.adPlaceholderTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.adPlaceholderSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
