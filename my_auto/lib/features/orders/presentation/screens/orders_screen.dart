import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_list_slot.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/orders/bloc/orders_list/orders_list_bloc.dart';
import 'package:my_auto/features/orders/bloc/orders_list/orders_list_event.dart';
import 'package:my_auto/features/orders/bloc/orders_list/orders_list_state.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_shimmer_list.dart';
import 'package:my_auto/features/orders/presentation/widgets/orders_empty_state.dart';
import 'package:my_auto/features/orders/presentation/widgets/orders_marketplace_header.dart';
import 'package:my_auto/features/orders/presentation/widgets/orders_tab_bar.dart';
import 'package:my_auto/features/orders/presentation/widgets/premium_order_card.dart';
import 'package:my_auto/generated/l10n.dart';

/// Marketplace-style requests feed (I need).
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    this.authorId,
    this.partCategoryId,
    this.matchSellerCategories = false,
    this.embedded = false,
  });

  final String? authorId;
  final String? partCategoryId;
  final bool matchSellerCategories;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().auth?.user.id;
    return BlocProvider(
      create: (_) => OrdersListBloc(
        repository: ordersRepository,
        currentUserId: userId,
      )..add(OrdersListStarted(
          authorId: authorId,
          partCategoryId: partCategoryId,
          matchSellerCategories: matchSellerCategories,
        )),
      child: _OrdersView(embedded: embedded),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView({required this.embedded});

  final bool embedded;

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrdersListBloc>().add(const OrdersListLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final ok = await AuthGuard.requireAuth(
      context,
      pending: const PendingCreateOrder(),
    );
    if (!ok || !mounted) return;
    if (!AuthGuard.isAuthenticated(context)) return;
    final created = await context.push<bool>(RoutesName.createOrder);
    if (created == true && mounted) {
      context.read<OrdersListBloc>().add(const OrdersListRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final bottomPad = widget.embedded
        ? 24.0
        : listPaddingAboveBottomNav(context);

    final content = RefreshIndicator(
      color: colors.primary,
      onRefresh: () async {
        context.read<OrdersListBloc>().add(const OrdersListRefreshed());
        await context.read<OrdersListBloc>().stream.firstWhere(
              (st) =>
                  st.status != OrdersListStatus.loading ||
                  st.visibleOrders.isNotEmpty,
            );
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: BlocBuilder<OrdersListBloc, OrdersListState>(
              buildWhen: (p, c) =>
                  p.stats.activeRequests != c.stats.activeRequests ||
                  p.tab != c.tab,
              builder: (context, state) => OrdersMarketplaceHeader(
                searchController: _searchController,
                onSearchChanged: (v) => context
                    .read<OrdersListBloc>()
                    .add(OrdersListSearchChanged(v)),
                onCreate: _openCreate,
                activeCount: state.stats.activeRequests,
                filters: OrdersTabBar(
                  selected: state.tab,
                  onChanged: (tab) => context
                      .read<OrdersListBloc>()
                      .add(OrdersListTabChanged(tab)),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
          BlocBuilder<OrdersListBloc, OrdersListState>(
            builder: (context, state) {
              switch (state.status) {
                case OrdersListStatus.loading:
                  return const SliverFillRemaining(
                    child: OrderShimmerList(),
                  );
                case OrdersListStatus.empty:
                  return SliverFillRemaining(
                    child: OrdersEmptyState(onCreate: _openCreate),
                  );
                case OrdersListStatus.error:
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.wifiOff,
                              size: 40,
                              color: colors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              GraphqlErrorUi.localizeRaw(
                                context,
                                state.failure?.message,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context
                                  .read<OrdersListBloc>()
                                  .add(const OrdersListRefreshed()),
                              child: Text(s.update),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                default:
                  final orders = state.visibleOrders;
                  final loadingMore =
                      state.status == OrdersListStatus.loadingMore;
                  const crossAxisCount = 2;
                  final rowCount = (orders.length / crossAxisCount).ceil();
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      MarketUi.spacingMD,
                      0,
                      MarketUi.spacingMD,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, rowIndex) {
                          if (rowIndex >= rowCount) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          final start = rowIndex * crossAxisCount;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AdListSlot(
                                listIndex: start,
                                surface: AdSurface.announcement,
                                interval: 6,
                                height: 110,
                                margin: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                              ),
                              // Fixed row height — IntrinsicHeight forces
                              // double layout passes and freezes fast flings.
                              SizedBox(
                                height: 210,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0;
                                        i < crossAxisCount;
                                        i++) ...[
                                      if (i > 0) const SizedBox(width: 12),
                                      Expanded(
                                        child: start + i < orders.length
                                            ? Builder(
                                                builder: (context) {
                                                  final order =
                                                      orders[start + i];
                                                  final isMine = context
                                                          .read<
                                                              AuthProvider>()
                                                          .auth
                                                          ?.user
                                                          .id ==
                                                      order.author?.id;
                                                  return PremiumOrderCard(
                                                    order: order,
                                                    compact: true,
                                                    isFavorite: state
                                                        .favoriteIds
                                                        .contains(order.id),
                                                    onFavoriteToggle: () =>
                                                        context
                                                            .read<
                                                                OrdersListBloc>()
                                                            .add(
                                                              OrdersListFavoriteToggled(
                                                                order.id,
                                                              ),
                                                            ),
                                                    onClose: isMine
                                                        ? () => context
                                                            .read<
                                                                OrdersListBloc>()
                                                            .add(
                                                              OrdersListCloseRequested(
                                                                order.id,
                                                              ),
                                                            )
                                                        : null,
                                                  );
                                                },
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                        childCount: rowCount + (loadingMore ? 1 : 0),
                        addAutomaticKeepAlives: false,
                      ),
                    ),
                  );
              }
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: widget.embedded
          ? content
          : AppSafeArea(bottom: false, child: content),
    );
  }
}
