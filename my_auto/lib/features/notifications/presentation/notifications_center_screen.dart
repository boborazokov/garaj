import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/notifications/bloc/notifications_bloc.dart';
import 'package:my_auto/features/notifications/bloc/notifications_event.dart';
import 'package:my_auto/features/notifications/bloc/notifications_state.dart';
import 'package:my_auto/features/notifications/data/models/app_notification.dart';
import 'package:my_auto/features/notifications/data/repositories/notifications_inbox_repository.dart';
import 'package:my_auto/features/notifications/notifications_constants.dart';
import 'package:my_auto/features/notifications/presentation/notification_l10n.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart' show pushRouter;
import 'package:my_auto/widgets/common/app_bar.dart';

enum _InboxFilter { all, messages, activity, payments }

enum _NotifCategory { messages, activity, payments }

_NotifCategory _categoryFor(String type) {
  switch (type) {
    case PushEventTypes.chat:
    case PushEventTypes.orderReply:
    case PushEventTypes.sellerResponse:
      return _NotifCategory.messages;
    case PushEventTypes.walletTopUp:
    case PushEventTypes.walletSpend:
      return _NotifCategory.payments;
    default:
      return _NotifCategory.activity;
  }
}

String _typeLabelFor(S s, String type) {
  switch (type) {
    case PushEventTypes.chat:
      return s.messages;
    case PushEventTypes.orderReply:
    case PushEventTypes.orderMatched:
    case PushEventTypes.sellerResponse:
      return s.orders;
    case PushEventTypes.walletTopUp:
    case PushEventTypes.walletSpend:
      return s.walletTitle;
    case PushEventTypes.promotedExpired:
    case PushEventTypes.favoriteMatched:
      return s.topProducts;
    case PushEventTypes.workshopBooking:
      return s.services;
    case PushEventTypes.accountVerified:
      return s.verifiedAccountTitle;
    default:
      return s.homeAlertsPreviewSection;
  }
}

/// Push and system alerts — separate from [ChatsScreen] (messages).
class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  static Future<void> open(BuildContext context) async {
    final ok = await AuthGuard.requireAuth(
      context,
      pending: const PendingRoute(path: RoutesName.notifications),
    );
    if (!context.mounted || !ok) return;
    if (AuthGuard.isAuthenticated(context)) {
      context.push(RoutesName.notifications);
    }
  }

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final _scrollController = ScrollController();

  bool _requestingPermission = false;
  bool _inboxLoading = true;
  bool _loadingMore = false;
  Object? _inboxError;
  List<AppNotification> _items = [];
  int _unreadCount = 0;
  int _page = 1;
  bool _hasNextPage = false;
  _InboxFilter _filter = _InboxFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPermission();
      _loadInbox(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasNextPage || _loadingMore || _inboxLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 160) {
      _loadMore();
    }
  }

  Future<void> _syncPermission() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (!mounted) return;
      final granted = _isGranted(settings.authorizationStatus);
      context
          .read<NotificationsBloc>()
          .add(NotificationsPermissionChanged(granted));
    } catch (_) {}
  }

  bool _isGranted(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _loadInbox({required bool reset}) async {
    if (reset) {
      setState(() {
        _inboxLoading = true;
        _inboxError = null;
        _page = 1;
      });
    }
    try {
      final results = await Future.wait([
        notificationsInboxRepository.fetchInbox(page: 1, limit: 30),
        notificationsInboxRepository.unreadCount(),
      ]);
      if (!mounted) return;
      final page = results[0] as PaginatedAppNotifications;
      setState(() {
        _items = page.items;
        _hasNextPage = page.hasNextPage;
        _page = 1;
        _unreadCount = results[1] as int;
        _inboxLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _inboxError = e;
        _inboxLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasNextPage) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final page = await notificationsInboxRepository.fetchInbox(
        page: next,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _hasNextPage = page.hasNextPage;
        _page = next;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await notificationsInboxRepository.markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items.map((n) => n.markRead()).toList();
        _unreadCount = 0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openNotification(AppNotification notification) async {
    if (!notification.isRead) {
      try {
        await notificationsInboxRepository.markRead(notification.id);
        if (mounted) {
          setState(() {
            _items = _items
                .map(
                  (n) => n.id == notification.id ? n.markRead() : n,
                )
                .toList();
            _unreadCount = (_unreadCount - 1).clamp(0, 999999);
          });
        }
      } catch (_) {}
    }

    final payload = _payloadForNotification(notification);
    final handled = pushRouter.route(payload);
    if (!handled && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(S.of(context).errorOccurred)),
      );
    }
  }

  Map<String, dynamic> _payloadForNotification(AppNotification notification) {
    final payload = <String, dynamic>{
      PushDataKeys.type: notification.type,
    };

    final link = notification.deepLink?.trim();
    if (link != null && link.isNotEmpty) {
      payload[PushDataKeys.deepLink] = link;
      final uri = Uri.tryParse(
        link.startsWith('http')
            ? link
            : (link.startsWith('/') ? link : '/$link'),
      );
      if (uri != null) {
        final params = uri.queryParameters;
        final partId = params['id'] ?? params['partId'];
        if (partId != null && partId.isNotEmpty) {
          payload[PushDataKeys.partId] = partId;
        }
        final orderId = params['orderId'];
        if (orderId != null && orderId.isNotEmpty) {
          payload[PushDataKeys.orderId] = orderId;
        }
        final conversationId = params['conversationId'];
        if (conversationId != null && conversationId.isNotEmpty) {
          payload[PushDataKeys.conversationId] = conversationId;
        }
        final sellerId = params['sellerId'];
        if (sellerId != null && sellerId.isNotEmpty) {
          payload[PushDataKeys.sellerId] = sellerId;
        }
      }
    }

    return payload;
  }

  Future<void> _enableAlerts() async {
    setState(() => _requestingPermission = true);
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (!mounted) return;
      final granted = _isGranted(settings.authorizationStatus);
      context
          .read<NotificationsBloc>()
          .add(NotificationsPermissionChanged(granted));
      if (granted) {
        context
            .read<NotificationsBloc>()
            .add(const NotificationsBootstrapped());
      }
    } finally {
      if (mounted) setState(() => _requestingPermission = false);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case PushEventTypes.chat:
        return LucideIcons.messageCircle;
      case PushEventTypes.orderReply:
        return LucideIcons.shoppingBag;
      case PushEventTypes.orderMatched:
        return LucideIcons.megaphone;
      case PushEventTypes.favoriteMatched:
      case PushEventTypes.promotedExpired:
        return LucideIcons.sparkles;
      case PushEventTypes.sellerResponse:
        return LucideIcons.package;
      case PushEventTypes.accountVerified:
        return LucideIcons.badgeCheck;
      case PushEventTypes.workshopBooking:
        return LucideIcons.wrench;
      case PushEventTypes.walletTopUp:
      case PushEventTypes.walletSpend:
        return LucideIcons.wallet;
      default:
        return LucideIcons.bell;
    }
  }

  int _countFor(_InboxFilter filter) {
    switch (filter) {
      case _InboxFilter.all:
        return _items.length;
      case _InboxFilter.messages:
        return _items
            .where((n) => _categoryFor(n.type) == _NotifCategory.messages)
            .length;
      case _InboxFilter.activity:
        return _items
            .where((n) => _categoryFor(n.type) == _NotifCategory.activity)
            .length;
      case _InboxFilter.payments:
        return _items
            .where((n) => _categoryFor(n.type) == _NotifCategory.payments)
            .length;
    }
  }

  List<AppNotification> get _visible {
    switch (_filter) {
      case _InboxFilter.all:
        return _items;
      case _InboxFilter.messages:
        return _items
            .where((n) => _categoryFor(n.type) == _NotifCategory.messages)
            .toList();
      case _InboxFilter.activity:
        return _items
            .where((n) => _categoryFor(n.type) == _NotifCategory.activity)
            .toList();
      case _InboxFilter.payments:
        return _items
            .where((n) => _categoryFor(n.type) == _NotifCategory.payments)
            .toList();
    }
  }

  List<_DayGroup> _grouped(List<AppNotification> items, String languageCode) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final map = <String, List<AppNotification>>{};

    for (final n in items) {
      final local = n.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final key = day == today
          ? 'today'
          : day == yesterday
              ? 'yesterday'
              : cardPostedLabel(local, languageCode: languageCode);
      map.putIfAbsent(key, () => []).add(n);
    }

    return map.entries
        .map((e) => _DayGroup(labelKey: e.key, items: e.value))
        .toList();
  }

  String _dayLabel(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (key) {
      case 'today':
        return switch (lang) {
          'ru' => 'Сегодня',
          'en' => 'Today',
          _ => 'Bugun',
        };
      case 'yesterday':
        return switch (lang) {
          'ru' => 'Вчера',
          'en' => 'Yesterday',
          _ => 'Kecha',
        };
      default:
        return key;
    }
  }

  String _clock(DateTime local) {
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _relativeTime(DateTime when, String languageCode) {
    final local = when.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return _clock(local);
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24 && local.day == now.day) return _clock(local);
    return '${cardPostedLabel(local, languageCode: languageCode)} · ${_clock(local)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final visible = _visible;
    final groups = _grouped(visible, languageCode);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(
        title: s.notificationsCenterTitle,
        actions: _unreadCount > 0
            ? [
                TextButton(
                  onPressed: _markAllRead,
                  child: Text(s.notificationsMarkAllRead),
                ),
              ]
            : null,
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listenWhen: (p, c) => p.failureMessage != c.failureMessage,
        listener: (context, state) {
          final msg = state.failureMessage;
          if (msg != null && msg.isNotEmpty) {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              SnackBar(content: Text(S.of(context).errorOccurred)),
            );
          }
        },
        builder: (context, state) {
          final alertsOn = state.permissionGranted ||
              state.status == NotificationsStatus.ready;
          final showEnableCta = !alertsOn &&
              state.status != NotificationsStatus.bootstrapping;

          return RefreshIndicator(
            color: colors.primary,
            onRefresh: () async {
              final bloc = context.read<NotificationsBloc>();
              await _syncPermission();
              if (!mounted) return;
              bloc.add(const NotificationsBootstrapped());
              await _loadInbox(reset: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (showEnableCta)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MarketUi.spacingMD,
                        AppSpacing.s,
                        MarketUi.spacingMD,
                        0,
                      ),
                      child: _PermissionBanner(
                        requesting: _requestingPermission,
                        bootstrapping:
                            state.status == NotificationsStatus.bootstrapping,
                        onEnable: _enableAlerts,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MarketUi.spacingMD,
                        AppSpacing.s,
                        MarketUi.spacingMD,
                        0,
                      ),
                      child: _QuietStatus(
                        title: s.notificationsAlertsOn,
                        subtitle: s.notificationsCenterFooterHint,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      MarketUi.spacingMD,
                      AppSpacing.l,
                      MarketUi.spacingMD,
                      AppSpacing.s,
                    ),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label:
                                '${s.seeAll} · ${_countFor(_InboxFilter.all)}',
                            selected: _filter == _InboxFilter.all,
                            onTap: () =>
                                setState(() => _filter = _InboxFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label:
                                '${s.messages} · ${_countFor(_InboxFilter.messages)}',
                            selected: _filter == _InboxFilter.messages,
                            onTap: () => setState(
                              () => _filter = _InboxFilter.messages,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label:
                                '${s.homeAlertsPreviewSection} · ${_countFor(_InboxFilter.activity)}',
                            selected: _filter == _InboxFilter.activity,
                            onTap: () => setState(
                              () => _filter = _InboxFilter.activity,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label:
                                '${s.walletTitle} · ${_countFor(_InboxFilter.payments)}',
                            selected: _filter == _InboxFilter.payments,
                            onTap: () => setState(
                              () => _filter = _InboxFilter.payments,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_inboxLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                else if (_inboxError != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: _inboxError.toString(),
                      onRetry: () => _loadInbox(reset: true),
                    ),
                  )
                else if (visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      onShowAll: _filter != _InboxFilter.all
                          ? () => setState(() => _filter = _InboxFilter.all)
                          : null,
                    ),
                  )
                else ...[
                  for (final group in groups) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          MarketUi.spacingMD,
                          AppSpacing.m,
                          MarketUi.spacingMD,
                          AppSpacing.s,
                        ),
                        child: Text(
                          _dayLabel(context, group.labelKey),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final n = group.items[i];
                          return _NotificationTile(
                            notification: n,
                            icon: _iconForType(n.type),
                            typeLabel: _typeLabelFor(s, n.type),
                            timeLabel:
                                _relativeTime(n.createdAt, languageCode),
                            showDivider: i < group.items.length - 1,
                            onTap: () => _openNotification(n),
                          );
                        },
                        childCount: group.items.length,
                      ),
                    ),
                  ],
                  if (_loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    ),
                ],
                if (!kIsWeb && Platform.isIOS && !alertsOn)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Text(
                        s.notificationsIosSettingsHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DayGroup {
  const _DayGroup({required this.labelKey, required this.items});
  final String labelKey;
  final List<AppNotification> items;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.textPrimary : colors.surface,
      borderRadius: AppRadius.rXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rXl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rXl,
            border: Border.all(
              color: selected ? colors.textPrimary : colors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? colors.background : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.requesting,
    required this.bootstrapping,
    required this.onEnable,
  });

  final bool requesting;
  final bool bootstrapping;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MarketUi.productSection(context, colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.rS,
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  LucideIcons.bellOff,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.notificationsAlertsOff,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bootstrapping
                          ? '${s.notificationsEnableHint}…'
                          : s.notificationsEnableHint,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: requesting ? null : onEnable,
            icon: requesting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : const Icon(LucideIcons.bell, size: 18),
            label: Text(s.notificationsEnableButton),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietStatus extends StatelessWidget {
  const _QuietStatus({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: MarketUi.productSection(context, colors),
      child: Row(
        children: [
          Icon(LucideIcons.bell, size: 18, color: colors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.typeLabel,
    required this.timeLabel,
    required this.onTap,
    this.showDivider = true,
  });

  final AppNotification notification;
  final IconData icon;
  final String typeLabel;
  final String timeLabel;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final copy = localizeNotification(S.of(context), notification);
    final unread = !notification.isRead;

    return Material(
      color: unread
          ? colors.primary.withValues(alpha: 0.04)
          : colors.background,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceMuted,
                      border: Border.all(color: colors.border),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: 20,
                      color: unread ? colors.primary : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                copy.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: unread
                                    ? colors.primary
                                    : colors.textMuted,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          typeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                copy.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: unread
                                      ? colors.textPrimary
                                      : colors.textMuted,
                                  fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  height: 1.35,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (unread) ...[
                              const SizedBox(width: 10),
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                indent: 76,
                color: colors.border.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onShowAll});

  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              LucideIcons.inbox,
              size: 36,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            s.notificationsCenterEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.45,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onShowAll != null) ...[
            const SizedBox(height: AppSpacing.l),
            TextButton(
              onPressed: onShowAll,
              child: Text(s.seeAll),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.wifiOff, size: 40, color: colors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: Text(s.update),
          ),
        ],
      ),
    );
  }
}
