import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';

/// Four marketplace CTAs — icon top, short label, fixed width tiles.
class PremiumQuickActionsBar extends StatelessWidget {
  const PremiumQuickActionsBar({
    super.key,
    required this.onOpenMap,
  });

  final VoidCallback onOpenMap;

  Future<void> _authThen(BuildContext context, String route) async {
    final ok = await AuthGuard.requireAuth(
      context,
      pending: PendingRoute(path: route),
    );
    if (context.mounted && ok) {
      await Future.microtask(() {});
      if (context.mounted) context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    final items = <({IconData icon, String label, Future<void> Function() onTap})>[
      (
        icon: LucideIcons.packagePlus,
        label: s.homeQuickSellProduct,
        onTap: () => _authThen(context, RoutesName.addProduct),
      ),
      (
        icon: LucideIcons.clipboardList,
        label: s.homeQuickCreateOrder,
        onTap: () => _authThen(context, RoutesName.createOrder),
      ),
      (
        icon: LucideIcons.wrench,
        label: s.homeQuickAddWorkshop,
        onTap: () => _authThen(context, RoutesName.createWorkshop),
      ),
      (
        icon: LucideIcons.mapPin,
        label: s.searchHubOpenMap,
        onTap: () async => onOpenMap(),
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
        separatorBuilder: (_, __) =>
            const SizedBox(width: MarketUi.spacingSM),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final e = items[i];
          return SizedBox(
            width: 86,
            child: Material(
              color: colors.surface,
              elevation: 0,
              shadowColor: Colors.transparent,
              borderRadius: MarketUi.cardRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: e.onTap,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: MarketUi.cardRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.surface,
                        colors.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    boxShadow: MarketUi.softElev(context),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(e.icon,
                            color: colors.primary, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          e.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            height: 1.15,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
