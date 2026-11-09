import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';

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
    return Material(
      color: colors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MarketUi.spacingMD,
          AppSpacing.s,
          MarketUi.spacingMD,
          stickyBottomPadding(context, keyboardExtra: 8, homeExtra: 12),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: MarketUi.actionDock(context, colors),
          child: Row(
            children: [
              if (onSecondary != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.rM,
                      ),
                    ),
                    child: Text(secondaryLabel ?? 'Back'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.rM,
                    ),
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
