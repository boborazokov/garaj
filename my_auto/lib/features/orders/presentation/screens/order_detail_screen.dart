import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/presentation/presentation.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_bloc.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_event.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_state.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/core/errors/api_error_code.dart';
import 'package:my_auto/core/errors/api_error_mapper.dart';
import 'package:my_auto/core/errors/api_error_payload.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/orders/presentation/utils/order_author_chat.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_owner_actions.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_images.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_response_card.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDetailBloc(repository: ordersRepository)
        ..add(OrderDetailOpened(orderId)),
      child: _OrderDetailView(orderId: orderId),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state.status == OrderDetailStatus.loading) {
            return const OrderDetailSkeleton();
          }

          String? err;
          if (state.failure != null) {
            final code = ApiErrorCode.tryParse(state.failure!.message);
            err = code != null
                ? ApiErrorMapper.localize(
                    context,
                    ApiErrorPayload(code: code),
                  )
                : state.failure!.message;
          } else if (state.status == OrderDetailStatus.error ||
              state.order == null) {
            err = s.errorOrderNotFound;
          }
          if (err != null) {
            return AsyncErrorPane(
              message: err,
              onRetry: () => context.read<OrderDetailBloc>().add(
                    OrderDetailOpened(orderId),
                  ),
            );
          }

          final order = state.order!;
          final userId = context.read<AuthProvider>().auth?.user.id;
          final isOwner = userId == order.author?.id;
          final isClosed = order.status == OrderStatus.closed;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 0,
                title: Text(
                  s.searchHubSectionOrders,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _RequestSummaryCard(order: order, isOwner: isOwner),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _ActionsBlock(
                    order: order,
                    isOwner: isOwner,
                    isClosed: isClosed,
                    onRespond: () => _showRespondSheet(context, order),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.orderDetailOffersTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: AppRadius.rM,
                        ),
                        child: Text(
                          s.orderDetailOffersCount(state.responses.length),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.responses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.rXl,
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.inbox,
                            size: 40,
                            color: colors.textMuted.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.orderDetailNoOffers,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final r = state.responses[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: OrderResponseCard(
                          response: r,
                          request: order,
                          onChat: () =>
                              _openChat(context, r.seller.id, r.seller.name),
                          onCall: (r.seller.phone ?? order.phone).isNotEmpty
                              ? () => launchUrl(
                                    Uri.parse(
                                      'tel:${r.seller.phone ?? order.phone}',
                                    ),
                                  )
                              : null,
                        ),
                      );
                    },
                    childCount: state.responses.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    String sellerId,
    String name,
  ) async {
    final conversation = await chatRepository.createConversation(
      recipientId: sellerId,
    );
    if (!context.mounted) return;
    context.push('${RoutesName.chatDetail}/${conversation.id}', extra: name);
  }

  void _showRespondSheet(BuildContext context, Order order) {
    final s = S.of(context);
    final textCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final colors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.orderDetailYourOffer,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (order.requestContextLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${s.orderDetailLookingFor}: ${order.requestContextLabel}',
                style: TextStyle(color: colors.textMuted, height: 1.35),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: s.orderDetailOfferMessageHint,
                border: OutlineInputBorder(borderRadius: AppRadius.rL),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: s.orderDetailOfferPriceHint,
                border: OutlineInputBorder(borderRadius: AppRadius.rL),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<OrderDetailBloc>().add(
                      OrderDetailRespondSubmitted(
                        text: textCtrl.text,
                        offeredPrice: int.tryParse(priceCtrl.text),
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: Text(s.orderDetailSubmitOffer),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({
    required this.order,
    required this.isOwner,
  });

  final Order order;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final isClosed = order.status == OrderStatus.closed;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: colors.border.withValues(alpha: 0.45)),
        boxShadow: AppShadows.card(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.images.isNotEmpty) ...[
              OrderDetailGallery(images: order.images),
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    LucideIcons.clipboardList,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      if (order.requestContextLabel.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${s.orderDetailLookingFor}: ${order.requestContextLabel}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusPill(
                  label: isClosed ? s.orderStatusClosed : s.orderStatusActive,
                  isClosed: isClosed,
                ),
              ],
            ),
            if (order.description.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                order.description.trim(),
                style: const TextStyle(height: 1.45, fontSize: 15),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: LucideIcons.wallet,
                  label: order.budget > 0
                      ? '${order.currency ?? 'UZS'} ${order.budget}'
                      : s.orderDetailBudgetNegotiable,
                ),
                if (order.location?.isNotEmpty == true)
                  _MetaChip(
                    icon: LucideIcons.mapPin,
                    label: order.location!,
                  ),
                _MetaChip(
                  icon: LucideIcons.clock,
                  label:
                      '${s.orderDetailPosted} ${DateFormat('dd MMM yyyy').format(order.createdAt.toLocal())}',
                ),
                if (order.urgency == OrderUrgency.urgent)
                  _MetaChip(
                    icon: LucideIcons.flame,
                    label: s.orderUrgencyUrgent,
                  ),
              ],
            ),
            if (isOwner) ...[
              const SizedBox(height: 16),
              OrderOwnerActions(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionsBlock extends StatelessWidget {
  const _ActionsBlock({
    required this.order,
    required this.isOwner,
    required this.isClosed,
    required this.onRespond,
  });

  final Order order;
  final bool isOwner;
  final bool isClosed;
  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;

    if (isOwner) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (order.author != null)
          FilledButton.tonalIcon(
            onPressed: () => openOrderAuthorChat(context, order),
            icon: const Icon(LucideIcons.messageSquare),
            label: Text(s.orderDetailMessageBuyer),
          ),
        if (!isClosed) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onRespond,
            icon: const Icon(LucideIcons.send),
            label: Text(s.orderDetailSendOffer),
          ),
        ],
        if (isClosed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              s.orderStatusClosed,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isClosed});

  final String label;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isClosed
            ? colors.textMuted.withValues(alpha: 0.12)
            : colors.success.withValues(alpha: 0.14),
        borderRadius: AppRadius.rM,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isClosed ? colors.textMuted : colors.success,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.rM,
        border: Border.all(color: colors.border.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
