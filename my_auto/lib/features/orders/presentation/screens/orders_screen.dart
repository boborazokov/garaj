import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/orders/bloc/orders_list/orders_list_bloc.dart';
import 'package:my_auto/features/orders/bloc/orders_list/orders_list_event.dart';
import 'package:my_auto/features/orders/bloc/orders_list/orders_list_state.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_shimmer_list.dart';
import 'package:my_auto/features/orders/presentation/widgets/orders_empty_state.dart';
import 'package:my_auto/features/orders/presentation/widgets/orders_marketplace_header.dart';
import 'package:my_auto/features/orders/presentation/widgets/premium_order_card.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';

/// Marketplace-style requests feed (OLX / RFQ inspired).
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
                  p.stats.activeRequests != c.stats.activeRequests,
              builder: (context, state) => OrdersMarketplaceHeader(
                searchController: _searchController,
                onSearchChanged: (v) => context
                    .read<OrdersListBloc>()
                    .add(OrdersListSearchChanged(v)),
                onCreate: _openCreate,
                activeCount: state.stats.activeRequests,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                      child: Text(
                        GraphqlErrorUi.localizeRaw(
                          context,
                          state.failure?.message,
                        ),
                      ),
                    ),
                  );
                default:
                  final orders = state.visibleOrders;
                  final loadingMore =
                      state.status == OrdersListStatus.loadingMore;
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= orders.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          final order = orders[index];
                          final isMine =
                              context.read<AuthProvider>().auth?.user.id ==
                                  order.author?.id;
                          return PremiumOrderCard(
                            order: order,
                            compact: true,
                            isFavorite:
                                state.favoriteIds.contains(order.id),
                            onFavoriteToggle: () => context
                                .read<OrdersListBloc>()
                                .add(OrdersListFavoriteToggled(order.id)),
                            onClose: isMine
                                ? () => context.read<OrdersListBloc>().add(
                                      OrdersListCloseRequested(order.id),
                                    )
                                : null,
                          );
                        },
                        childCount: orders.length + (loadingMore ? 1 : 0),
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
