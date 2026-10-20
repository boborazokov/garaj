import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/category_lucide_icon.dart';
import 'package:my_auto/features/orders/domain/entities/seller_matching_orders.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/orders/presentation/screens/orders_screen.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:provider/provider.dart';

/// Profile → E'lonlar: seller view of buyer requests matched to their categories.
class SellerMatchingOrdersScreen extends StatefulWidget {
  const SellerMatchingOrdersScreen({super.key});

  @override
  State<SellerMatchingOrdersScreen> createState() =>
      _SellerMatchingOrdersScreenState();
}

class _SellerMatchingOrdersScreenState
    extends State<SellerMatchingOrdersScreen> {
  SellerMatchingOrdersOverview? _overview;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ordersRepository.getSellerMatchingOrdersOverview();
      if (!mounted) return;
      setState(() {
        _overview = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final lang = context.watch<LocaleNotifier>().locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.sellerMatchingOrdersTitle),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator.adaptive()),
                ],
              )
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      Icon(LucideIcons.wifiOff,
                          size: 40, color: colors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        s.errorOccurred,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _load,
                        child: Text(s.retry),
                      ),
                    ],
                  )
                : _buildBody(context, s, colors, lang),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    S s,
    AppColors colors,
    String lang,
  ) {
    final overview = _overview!;
    if (overview.categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        children: [
          Icon(LucideIcons.packageOpen, size: 48, color: colors.textMuted),
          const SizedBox(height: 14),
          Text(
            s.sellerMatchingOrdersEmptyListings,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.sellerMatchingOrdersEmptyListingsHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push(RoutesName.addProduct),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(s.myProducts),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(
              RoutesName.sellerMatchingOrdersList,
              extra: const {'matchSellerCategories': true},
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.megaphone,
                        color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.sellerMatchingOrdersAll,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.sellerMatchingOrdersTotalHint(
                            overview.totalMatchingOrders,
                          ),
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _StatusChip(
                              label: s.sellerMatchingOrdersStatusActive,
                              color: colors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s.sellerMatchingOrdersOpenCount(
                                overview.totalMatchingOrders,
                              ),
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _CountBadge(count: overview.totalMatchingOrders),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight,
                      size: 18, color: colors.textMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          s.sellerMatchingOrdersByCategory,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...overview.categories.map((c) {
          final name = c.names.forLocale(lang);
          final icon = categoryIconByKey(c.key) ??
              categoryLucideIcon(c.icon) ??
              categoryIconByName(name) ??
              LucideIcons.package;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push(
                  RoutesName.sellerMatchingOrdersList,
                  extra: {
                    'partCategoryId': c.categoryId,
                    'title': name,
                    'matchSellerCategories': true,
                  },
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(icon, size: 20, color: colors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.sellerMatchingOrdersListingsHint(
                                c.listingsCount,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _StatusChip(
                                  label: s.sellerMatchingOrdersStatusActive,
                                  color: colors.success,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.sellerMatchingOrdersOpenCount(c.orderCount),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _CountBadge(count: c.orderCount),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight,
                          size: 18, color: colors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: count > 0
            ? colors.primary.withValues(alpha: 0.15)
            : colors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: count > 0 ? colors.primary : colors.textMuted,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// Filtered list of matching buyer requests for a seller category (or all).
class SellerMatchingOrdersListScreen extends StatelessWidget {
  const SellerMatchingOrdersListScreen({
    super.key,
    this.partCategoryId,
    this.title,
    this.matchSellerCategories = true,
  });

  final String? partCategoryId;
  final String? title;
  final bool matchSellerCategories;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppTopBar(
        title: title?.isNotEmpty == true
            ? title!
            : s.sellerMatchingOrdersAll,
      ),
      body: OrdersScreen(
        partCategoryId: partCategoryId,
        matchSellerCategories: matchSellerCategories,
        embedded: true,
      ),
    );
  }
}
