import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

class TrustBanner extends StatelessWidget {
  const TrustBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.shieldCheck, color: colors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.createProductTrustTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  s.createProductTrustBody,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
