import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/presentation/presentation.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_bloc.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_event.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_state.dart';
import 'package:my_auto/core/errors/api_error_code.dart';
import 'package:my_auto/core/errors/api_error_mapper.dart';
import 'package:my_auto/core/errors/api_error_payload.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/orders/presentation/utils/order_author_chat.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_owner_actions.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_images.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_response_card.dart';
import 'package:my_auto/features/orders/presentation/widgets/premium_order_card.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';
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
      body: BlocConsumer<OrderDetailBloc, OrderDetailState>(
        listenWhen: (prev, curr) =>
            curr.failure != null && prev.failure != curr.failure,
        listener: (context, state) {
          Toaster.error(
            GraphqlErrorUi.localizeRaw(context, state.failure?.message),
            context: context,
          );
        },
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
          final showSellerBar = !isOwner && !isClosed;
          final hasImages = order.images.isNotEmpty;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: colors.surface,
                      surfaceTintColor: Colors.transparent,
                      title: Text(
                        s.wantToBuyRequestBadge,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (hasImages)
                      SliverToBoxAdapter(
                        child: OrderDetailGallery(images: order.images),
                      )
                    else
                      SliverToBoxAdapter(
                        child: _NoPhotoBanner(colors: colors),
                      ),
                    SliverToBoxAdapter(
                      child: _RequestHeader(order: order),
                    ),
                    if (order.description.trim().isNotEmpty)
                      SliverToBoxAdapter(
                        child: _DescriptionBlock(
                          text: order.description.trim(),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _SpecsBlock(order: order),
                    ),
                    if (isOwner)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: OrderOwnerActions(order: order),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              s.orderDetailOffersCount(state.responses.length),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.textMuted,
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
                          child: _EmptyOffers(
                            isOwner: isOwner,
                            isClosed: isClosed,
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
                                onChat: () => _openChat(
                                  context,
                                  r.seller.id,
                                  r.seller.name,
                                ),
                                onCall:
                                    (r.seller.phone ?? order.phone).isNotEmpty
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
                    SliverToBoxAdapter(
                      child: SizedBox(height: showSellerBar ? 16 : 24),
                    ),
                    SliverToBoxAdapter(
                      child: _SimilarOrdersSection(order: order),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: showSellerBar ? 12 : 28),
                    ),
                  ],
                ),
              ),
              if (showSellerBar)
                _SellerBottomBar(
                  onMessage: () => openOrderAuthorChat(context, order),
                  onOffer: () => _openRespondSheet(context, order),
                  onCall: order.phone.trim().isNotEmpty
                      ? () => launchUrl(Uri.parse('tel:${order.phone}'))
                      : null,
                ),
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

  Future<void> _openRespondSheet(BuildContext context, Order order) async {
    final ok = await AuthGuard.requireAuth(context);
    if (!ok || !context.mounted) return;
    final bloc = context.read<OrderDetailBloc>();
    final colors = context.appColors;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _OfferSheet(order: order),
      ),
    );
  }
}

class _NoPhotoBanner extends StatelessWidget {
  const _NoPhotoBanner({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.primary.withValues(alpha: 0.08),
      child: SizedBox(
        height: 160,
        child: Center(
          child: Icon(
            LucideIcons.clipboardList,
            size: 40,
            color: colors.primary.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

/// Price-first header — same hierarchy as product detail.
class _RequestHeader extends StatelessWidget {
  const _RequestHeader({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);
    final isClosed = order.status == OrderStatus.closed;
    final vehicle = order.vehicleLabel.trim();
    final partRaw = order.partCategory?.name.trim() ?? '';
    final part = partRaw.isNotEmpty &&
            !RegExp(r'^[-–—._\s]+$').hasMatch(partRaw)
        ? partRaw
        : '';

    return Container(
      width: double.infinity,
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _budgetLabel(context, order),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.primary,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.wantToBuyBudget,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            order.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.25,
              color: colors.textPrimary,
            ),
          ),
          if (vehicle.isNotEmpty || part.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (part.isNotEmpty) part,
                if (vehicle.isNotEmpty) vehicle,
              ].join(' · '),
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                label: isClosed ? s.orderStatusClosed : s.orderStatusActive,
                fg: isClosed ? colors.textMuted : colors.success,
                bg: isClosed
                    ? colors.textMuted.withValues(alpha: 0.12)
                    : colors.success.withValues(alpha: 0.14),
              ),
              if (order.urgency == OrderUrgency.urgent)
                _MetaChip(
                  label: s.orderUrgencyUrgent,
                  fg: colors.danger,
                  bg: colors.danger.withValues(alpha: 0.12),
                ),
              if (order.isPromoted)
                _MetaChip(
                  label: s.promotedBadge,
                  fg: colors.onPrimary,
                  bg: colors.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.description,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              height: 1.45,
              fontSize: 15,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsBlock extends StatelessWidget {
  const _SpecsBlock({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final written = (order.location ?? '').trim();
    final place = looksLikeCoordinates(written) ? '' : written;

    final rows = <_Spec>[
      if (order.year != null)
        _Spec(
          icon: LucideIcons.calendar,
          label: s.createProductYearOptional
              .replaceAll(RegExp(r'\s*\(.*\)\s*'), '')
              .trim(),
          value: '${order.year}',
        ),
      if (order.author != null)
        _Spec(
          icon: LucideIcons.user,
          label: s.name,
          value: order.author!.name,
        ),
      if (place.isNotEmpty)
        _Spec(icon: LucideIcons.mapPin, label: s.address, value: place),
      _Spec(
        icon: LucideIcons.clock,
        label: s.orderDetailPosted,
        value: _formatDate(order.createdAt),
      ),
      if (order.viewsCount > 0)
        _Spec(
          icon: LucideIcons.eye,
          label: s.views,
          value: '${order.viewsCount}',
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _SpecRow(spec: rows[i]),
            if (i != rows.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.border.withValues(alpha: 0.55),
              ),
          ],
        ],
      ),
    );
  }
}

class _Spec {
  const _Spec({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.spec});
  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(spec.icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              spec.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              spec.value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  const _EmptyOffers({
    required this.isOwner,
    required this.isClosed,
  });

  final bool isOwner;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.inbox,
            size: 32,
            color: colors.textMuted.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 10),
          Text(
            s.orderDetailNoOffers,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isOwner && !isClosed) ...[
            const SizedBox(height: 8),
            Text(
              s.wantToBuySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
                height: 1.35,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SellerBottomBar extends StatelessWidget {
  const _SellerBottomBar({
    required this.onMessage,
    required this.onOffer,
    this.onCall,
  });

  final VoidCallback onMessage;
  final VoidCallback onOffer;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: colors.surface,
      elevation: 10,
      shadowColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
        child: Row(
          children: [
            if (onCall != null) ...[
              _IconAction(icon: LucideIcons.phone, onTap: onCall!),
              const SizedBox(width: 8),
            ],
            _IconAction(icon: LucideIcons.messageSquare, onTap: onMessage),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: onOffer,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.rL,
                    ),
                  ),
                  child: Text(
                    s.wantToBuyRespond,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.rL,
        side: BorderSide(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rL,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 20, color: colors.textPrimary),
        ),
      ),
    );
  }
}

String _budgetLabel(BuildContext context, Order order) {
  if (order.budget <= 0) return S.of(context).orderDetailBudgetNegotiable;
  final cur = order.currency?.isNotEmpty == true ? order.currency! : 'UZS';
  return '${_groupThousands(order.budget)}\u00A0$cur';
}

String _groupThousands(int value) {
  final digits = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write('\u00A0');
    buf.write(digits[i]);
  }
  return buf.toString();
}

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  return '$d.$m.${local.year}';
}

class _OfferSheet extends StatefulWidget {
  const _OfferSheet({required this.order});

  final Order order;

  @override
  State<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<_OfferSheet> {
  final _textCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  var _attempted = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  int? _parsePrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    final order = widget.order;

    return BlocConsumer<OrderDetailBloc, OrderDetailState>(
      listenWhen: (prev, curr) =>
          prev.isSubmittingResponse && !curr.isSubmittingResponse,
      listener: (context, state) {
        if (state.failure == null && context.mounted) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final busy = state.isSubmittingResponse;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.orderDetailYourOffer,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.title,
                style: TextStyle(
                  color: colors.textSecondary,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textCtrl,
                maxLines: 4,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: s.orderDetailOfferMessageHint,
                  border: OutlineInputBorder(borderRadius: AppRadius.rL),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceCtrl,
                enabled: !busy,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: s.orderDetailOfferPriceHint,
                  border: OutlineInputBorder(borderRadius: AppRadius.rL),
                ),
              ),
              if (_attempted && state.failure != null) ...[
                const SizedBox(height: 12),
                Text(
                  GraphqlErrorUi.localizeRaw(context, state.failure?.message),
                  style: TextStyle(
                    color: colors.danger,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: busy
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        setState(() => _attempted = true);
                        context.read<OrderDetailBloc>().add(
                              OrderDetailRespondSubmitted(
                                text: _textCtrl.text,
                                offeredPrice: _parsePrice(_priceCtrl.text),
                              ),
                            );
                      },
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(s.orderDetailSubmitOffer),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SimilarOrdersSection extends StatefulWidget {
  const _SimilarOrdersSection({required this.order});

  final Order order;

  @override
  State<_SimilarOrdersSection> createState() => _SimilarOrdersSectionState();
}

class _SimilarOrdersSectionState extends State<_SimilarOrdersSection> {
  List<Order> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final filter = <String, dynamic>{};
    final brandId = widget.order.brand?.id;
    final partId = widget.order.partCategory?.id;
    if (brandId != null && brandId.isNotEmpty) {
      filter['brand'] = brandId;
    } else if (partId != null && partId.isNotEmpty) {
      filter['partCategory'] = partId;
    }
    try {
      final page = await ordersRepository.getOrders(
        page: 1,
        limit: 10,
        filter: filter.isEmpty ? null : filter,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items
            .where((e) => e.id != widget.order.id)
            .take(8)
            .toList(growable: false);
      });
    } catch (_) {
      // Soft-fail: recommendations are optional.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.similarOrders,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 208,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final o = _items[i];
                return SizedBox(
                  width: 200,
                  child: PremiumOrderCard(
                    order: o,
                    compact: true,
                    isFavorite: false,
                    onFavoriteToggle: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
