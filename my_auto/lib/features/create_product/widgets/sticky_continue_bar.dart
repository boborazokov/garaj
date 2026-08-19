import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

class StickyContinueBar extends StatelessWidget {
  const StickyContinueBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondary,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        stickyBottomPadding(context, keyboardExtra: 8, homeExtra: 12),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: AppShadows.floating(context),
      ),
      child: Row(
        children: [
          if (onSecondary != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel ?? 'Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: enabled && !isLoading
                  ? () {
                      HapticFeedback.lightImpact();
                      onPressed?.call();
                    }
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
