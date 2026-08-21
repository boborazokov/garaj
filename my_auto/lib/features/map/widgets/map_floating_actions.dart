import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

/// Zoom + my-location vertical rail.
class MapFloatingActions extends StatelessWidget {
  const MapFloatingActions({
    super.key,
    required this.colors,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
    required this.locating,
    this.onRadius,
  });

  final AppColors colors;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;
  final bool locating;
  final VoidCallback? onRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colors.surface.withValues(alpha: 0.78)
              : colors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.border.withValues(alpha: isDark ? 0.25 : 0.45),
          ),
          boxShadow: AppShadows.floating(context),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn(LucideIcons.plus, onZoomIn),
            _divider(),
            _btn(LucideIcons.minus, onZoomOut),
            _divider(),
            if (onRadius != null) ...[
              _btn(LucideIcons.ruler, onRadius!),
              _divider(),
            ],
            _btn(
              LucideIcons.navigation,
              locating ? () {} : onMyLocation,
              highlight: true,
              loading: locating,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      width: 28,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colors.border.withValues(alpha: 0.4),
    );
  }

  Widget _btn(
    IconData icon,
    VoidCallback onTap, {
    bool highlight = false,
    bool loading = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: AppRadius.rS,
      child: SizedBox(
        width: 44,
        height: 40,
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              )
            : Icon(
                icon,
                size: 20,
                color: highlight ? colors.primary : colors.textPrimary,
              ),
      ),
    );
  }
}
