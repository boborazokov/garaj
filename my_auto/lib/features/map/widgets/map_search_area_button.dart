import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

class MapSearchAreaButton extends StatelessWidget {
  const MapSearchAreaButton({
    super.key,
    required this.colors,
    required this.onPressed,
    this.busy = false,
  });

  final AppColors colors;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryHover],
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.glow(colors.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                else
                  Icon(LucideIcons.refreshCw, size: 16, color: colors.onPrimary),
                const SizedBox(width: 8),
                Text(
                  'Search in this area',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
