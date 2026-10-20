import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/orders/orders_provider.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/orders/widgets/order_card.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/searchInput/index.dart';
import 'package:provider/provider.dart';

/// Public Orders / Announcements feed.
///
/// Used both as a stand-alone tab in the bottom-bar and as a landing
/// destination from the "Create Request" flow. Sorting is server-side
/// (promoted-in-region → promoted-global → newest).
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key, this.authorId, this.embedded = false});

  /// When set, only orders authored by this user are listed (used for the
  /// "My requests" screen).
  final String? authorId;

  /// `true` when hosted inside the bottom-bar (no back arrow + tab title).
  final bool embedded;

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final _scrollController = ScrollController();
  Timer? _debounce;
  OrdersProvider? _ordersProvider;

  Map<String, dynamic> get _filters => {
        if (widget.authorId != null) 'author': widget.authorId,
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ordersProvider ??= context.read<OrdersProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = _ordersProvider ?? context.read<OrdersProvider>();
      p.loadList(
        filters: _filters,
        search: p.searchController.text,
        reset: true,
      );
      p.searchController.addListener(_onSearchChanged);
    });

    _scrollController.addListener(() {
      final p = _ordersProvider;
      if (p == null) return;
      final search = p.searchController.text;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !p.isMoreLoadingFor(_filters, search: search) &&
          p.hasMoreFor(_filters, search: search)) {
        p.loadMore(filters: _filters, search: search);
      }
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (!mounted) return;
    final p = _ordersProvider;
    if (p == null) return;
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      p.loadList(
        filters: _filters,
        search: p.searchController.text,
        reset: true,
      );
    });
  }

  @override
  void dispose() {
    _ordersProvider?.searchController.removeListener(_onSearchChanged);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final provider = context.watch<OrdersProvider>();
    final search = provider.searchController.text;
    final orders = provider.ordersFor(_filters, search: search);
    final isLoading = provider.isLoadingFor(_filters, search: search);
    final isMoreLoading = provider.isMoreLoadingFor(_filters, search: search);

    return Scaffold(
      backgroundColor: colors.background,
      body: AppSafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchInput(
                      controller: provider.searchController,
                      hintText: s.search,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CreateButton(
                    onTap: () async {
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
                ],
              ),
            ),
            if (widget.embedded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Icon(LucideIcons.megaphone,
                        size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      s.orders,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: isLoading && orders.isEmpty
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : orders.isEmpty
                      ? _EmptyOrders()
                      : RefreshIndicator(
                          color: colors.primary,
                          onRefresh: () async {
                            await provider.loadList(
                              filters: _filters,
                              search: search,
                              reset: true,
                            );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount:
                                orders.length + (isMoreLoading ? 1 : 0),
                            itemBuilder: (_, i) {
                              final orderIndex = i;
                              if (orderIndex >= orders.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child:
                                          CircularProgressIndicator.adaptive()),
                                );
                              }
                              final order = orders[orderIndex];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: OrderCard(order: order),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.primary,
      borderRadius: AppRadius.rL,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(LucideIcons.plus, color: colors.onPrimary, size: 18),
              const SizedBox(width: 4),
              Text(
                S.of(context).createRequest,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rXl,
              ),
              child: Icon(LucideIcons.inbox,
                  size: 40, color: colors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              s.noOrders,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              s.noOrdersHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final ok = await AuthGuard.requireAuth(
                  context,
                  pending: const PendingCreateOrder(),
                );
                if (!ok || !context.mounted) return;
                if (AuthGuard.isAuthenticated(context)) {
                  context.push(RoutesName.createOrder);
                }
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(s.createRequest),
            ),
          ],
        ),
      ),
    );
  }
}
