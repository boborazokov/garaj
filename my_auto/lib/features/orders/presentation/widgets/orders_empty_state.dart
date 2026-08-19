import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({super.key, this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.2),
                    colors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                LucideIcons.packageSearch,
                size: 44,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.noOrders,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              s.noOrdersHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate ?? () => context.push(RoutesName.createOrder),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
              ),
              icon: const Icon(LucideIcons.plus),
              label: Text(s.createRequest),
            ),
          ],
        ),
      ),
    );
  }
}
