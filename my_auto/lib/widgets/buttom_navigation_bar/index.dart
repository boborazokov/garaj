import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/index.dart';
import 'package:my_auto/features/map/presentation/nearby_map_screen.dart';
import 'package:my_auto/features/orders/presentation/screens/orders_screen.dart';
import 'package:my_auto/features/profile/profile.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/generated/l10n.dart';

/// Marketplace shell: Home · Orders · create (+) · Map · Profile.
class MyBottomNavigationBar extends StatefulWidget {
  final int selectedTabIndex;

  const MyBottomNavigationBar({super.key, this.selectedTabIndex = 0});

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late int selectedIndex;
  late final Set<int> _builtTabs;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedTabIndex;
    _builtTabs = {selectedIndex};
  }

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
      _builtTabs.add(index);
    });
  }

  Widget _bodyForTab(int index) {
    switch (index) {
      case 0:
        return const Home();
      case 1:
        return const OrdersScreen(embedded: true);
      case 2:
        return const NearbyMapScreen(embedded: true);
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _lazyTab(int index) {
    if (!_builtTabs.contains(index)) {
      return const SizedBox.shrink();
    }
    return _bodyForTab(index);
  }

  void _openAddSheet() {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => _AddActionSheet(colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _lazyTab(0),
            _lazyTab(1),
            _lazyTab(2),
            _lazyTab(3),
          ],
        ),
      ),
      bottomNavigationBar: _AppBottomBar(
        selectedIndex: selectedIndex,
        onSelect: changeTab,
        onAddSheetOpen: _openAddSheet,
        labels: [s.home, s.search, s.services, s.profile],
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.background, width: 4),
        ),
        child: Icon(LucideIcons.plus, color: colors.background, size: 24),
      ),
    );
  }
}

class _AppBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddSheetOpen;
  final List<String> labels;

  const _AppBottomBar({
    required this.selectedIndex,
    required this.onSelect,
    required this.labels,
    required this.onAddSheetOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      minimum: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: AppShadows.floating(context),
          border: Border(top: BorderSide(color: colors.border)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: LucideIcons.home,
                activeIcon: LucideIcons.home,
                label: labels[0],
                isActive: selectedIndex == 0,
                onTap: () => onSelect(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: LucideIcons.search,
                activeIcon: LucideIcons.search,
                label: labels[1],
                isActive: selectedIndex == 1,
                onTap: () => onSelect(1),
              ),
            ),
            _CenterFab(onTap: onAddSheetOpen),
            Expanded(
              child: _NavItem(
                icon: LucideIcons.wrench300,
                activeIcon: LucideIcons.wrench300,
                label: labels[2],
                isActive: selectedIndex == 2,
                onTap: () => onSelect(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: LucideIcons.user,
                activeIcon: LucideIcons.user,
                label: labels[3],
                isActive: selectedIndex == 3,
                onTap: () => onSelect(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isActive ? colors.primary : colors.textMuted;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? colors.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddActionSheet extends StatelessWidget {
  final AppColors colors;
  const _AddActionSheet({required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + systemBottomInset(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            s.whatDoYouWantSell,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.appMarketplaceTagline,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 16),
          _AddOptionTile(
            colors: colors,
            icon: LucideIcons.packagePlus,
            iconColor: colors.primary,
            iconBg: colors.primary.withOpacity(0.15),
            title: s.homeQuickSellProduct,
            subtitle: s.parts,
            onTap: () async {
              Navigator.pop(context);
              final ok = await AuthGuard.requireAuth(
                context,
                pending: const PendingAddProduct(),
              );
              if (!ok || !context.mounted) return;
              if (AuthGuard.isAuthenticated(context)) {
                context.push(RoutesName.addProduct);
              }
            },
          ),
          const SizedBox(height: 10),
          _AddOptionTile(
            colors: colors,
            icon: LucideIcons.clipboardList,
            iconColor: colors.success,
            iconBg: colors.success.withOpacity(0.15),
            title: s.createOrder,
            subtitle: s.createRequestSubtitle,
            onTap: () async {
              Navigator.pop(context);
              final ok = await AuthGuard.requireAuth(
                context,
                pending: const PendingCreateOrder(),
              );
              if (!ok || !context.mounted) return;
              if (AuthGuard.isAuthenticated(context)) {
                context.push(RoutesName.createOrder);
              }
            },
          ),
          const SizedBox(height: 10),
          _AddOptionTile(
            colors: colors,
            icon: LucideIcons.wrench,
            iconColor: colors.info,
            iconBg: colors.info.withOpacity(0.12),
            title: s.homeQuickAddWorkshop,
            subtitle: s.services,
            onTap: () async {
              Navigator.pop(context);
              final ok = await AuthGuard.requireAuth(
                context,
                pending: const PendingRoute(path: RoutesName.createWorkshop),
              );
              if (!ok || !context.mounted) return;
              if (AuthGuard.isAuthenticated(context)) {
                context.push(RoutesName.createWorkshop);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.colors,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: colors.surfaceMuted,
      borderRadius: AppRadius.rL,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rL,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.rM,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: colors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
