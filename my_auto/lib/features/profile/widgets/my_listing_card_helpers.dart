import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

/// Visual tone for seller listing status chips.
enum MyListingStatusTone { success, warning, danger, muted }

/// Soft status pill used on seller listing cards
/// (active / pending moderation / rejected / archived).
class MyListingStatusChip extends StatelessWidget {
  const MyListingStatusChip({
    super.key,
    required this.label,
    this.tone,
    this.isActive,
  });

  final String label;
  final MyListingStatusTone? tone;

  /// Fallback when [tone] is omitted (workshop cards still pass this).
  final bool? isActive;

  MyListingStatusTone get _resolvedTone {
    if (tone != null) return tone!;
    return (isActive ?? true)
        ? MyListingStatusTone.success
        : MyListingStatusTone.danger;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    late final Color bg;
    late final Color fg;
    switch (_resolvedTone) {
      case MyListingStatusTone.success:
        bg = colors.successSoft;
        fg = colors.success;
      case MyListingStatusTone.warning:
        bg = AppPalette.warning100;
        fg = colors.warning;
      case MyListingStatusTone.danger:
        bg = colors.dangerSoft;
        fg = colors.danger;
      case MyListingStatusTone.muted:
        bg = colors.surfaceMuted;
        fg = colors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact action button row for seller listing cards.
class MyListingActionButton extends StatelessWidget {
  const MyListingActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isLoading = false,
    this.expanded = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = color ?? colors.textPrimary;
    final enabled = onTap != null && !isLoading;

    final child = Material(
      color: accent.withValues(alpha: 0.08),
      borderRadius: AppRadius.rS,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppRadius.rS,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                )
              else
                Icon(icon, size: 16, color: enabled ? accent : colors.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: enabled ? accent : colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expanded) return Expanded(child: child);
    return child;
  }
}

/// Highlighted promote / TOP action spanning full card width.
class MyListingPromoteButton extends StatelessWidget {
  const MyListingPromoteButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = isActive ? colors.primary : colors.warning;
    final fg = isActive ? colors.onPrimary : colors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rM,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.rM,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? LucideIcons.badgeCheck : LucideIcons.trendingUp,
                    size: 16,
                    color: fg,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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
