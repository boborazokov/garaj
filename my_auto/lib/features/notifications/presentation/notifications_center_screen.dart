import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
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
  bool _requestingPermission = false;
  bool _inboxLoading = true;
  Object? _inboxError;
  List<AppNotification> _items = [];
  int _unreadCount = 0;

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

  Future<void> _loadInbox() async {
    setState(() {
      _inboxLoading = true;
      _inboxError = null;
    });
    try {
      final results = await Future.wait([
        notificationsInboxRepository.fetchInbox(),
        notificationsInboxRepository.unreadCount(),
      ]);
      if (!mounted) return;
      final page = results[0] as PaginatedAppNotifications;
      setState(() {
        _items = page.items;
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
        link.startsWith('http') ? link : (link.startsWith('/') ? link : '/$link'),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPermission();
      _loadInbox();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case PushEventTypes.chat:
        return LucideIcons.messageCircle;
      case PushEventTypes.orderReply:
        return LucideIcons.shoppingBag;
      case PushEventTypes.newFollower:
        return LucideIcons.users;
      case PushEventTypes.favoriteMatched:
      case PushEventTypes.promotedExpired:
        return LucideIcons.sparkles;
      case PushEventTypes.sellerResponse:
        return LucideIcons.package;
      case PushEventTypes.accountVerified:
        return LucideIcons.badgeCheck;
      case PushEventTypes.workshopBooking:
        return LucideIcons.wrench;
      default:
        return LucideIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

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
              await _syncPermission();
              context
                  .read<NotificationsBloc>()
                  .add(const NotificationsBootstrapped());
              await _loadInbox();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _StatusCard(
                  alertsOn: alertsOn,
                  bootstrapping:
                      state.status == NotificationsStatus.bootstrapping,
                  title: alertsOn
                      ? s.notificationsAlertsOn
                      : s.notificationsAlertsOff,
                  subtitle: alertsOn
                      ? s.notificationsCenterFooterHint
                      : s.notificationsEnableHint,
                ),
                if (showEnableCta) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _requestingPermission ? null : _enableAlerts,
                      icon: _requestingPermission
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onPrimary,
                              ),
                            )
                          : Icon(LucideIcons.bell, color: colors.onPrimary),
                      label: Text(s.notificationsEnableButton),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.notificationsRecent,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (_unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_inboxLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                else if (_inboxError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(
                          _inboxError.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadInbox,
                          child: Text(s.update),
                        ),
                      ],
                    ),
                  )
                else if (_items.isEmpty)
                  Column(
                    children: [
                      Center(
                        child: Icon(
                          LucideIcons.inbox,
                          size: 56,
                          color: colors.textMuted.withValues(alpha: .22),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.notificationsCenterEmptyBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  ..._items.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationTile(
                        notification: n,
                        icon: _iconForType(n.type),
                        timeLabel: DateFormat.MMMd().add_jm().format(
                              n.createdAt.toLocal(),
                            ),
                        onTap: () => _openNotification(n),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  s.notificationsWhatYouGet,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _TopicRow(
                  icon: LucideIcons.messageCircle,
                  label: s.notificationsTopicMessages,
                ),
                _TopicRow(
                  icon: LucideIcons.shoppingBag,
                  label: s.notificationsTopicOrders,
                ),
                _TopicRow(
                  icon: LucideIcons.users,
                  label: s.notificationsTopicFollowers,
                ),
                _TopicRow(
                  icon: LucideIcons.wrench,
                  label: s.notificationsTopicWorkshops,
                ),
                _TopicRow(
                  icon: LucideIcons.sparkles,
                  label: s.notificationsTopicPromos,
                ),
                if (!kIsWeb && Platform.isIOS && !alertsOn) ...[
                  const SizedBox(height: 20),
                  Text(
                    s.notificationsIosSettingsHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.timeLabel,
    required this.onTap,
  });

  final AppNotification notification;
  final IconData icon;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final copy = localizeNotification(S.of(context), notification);
    return Material(
      color: notification.isRead
          ? colors.surface
          : colors.primary.withValues(alpha: .06),
      borderRadius: AppRadius.rL,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(
              color: notification.isRead
                  ? colors.border
                  : colors.primary.withValues(alpha: .25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        copy.body,
                        style: TextStyle(
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.alertsOn,
    required this.bootstrapping,
    required this.title,
    required this.subtitle,
  });

  final bool alertsOn;
  final bool bootstrapping;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.card(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (alertsOn ? colors.success : colors.warning)
                    .withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                alertsOn ? LucideIcons.bell : LucideIcons.bellOff,
                color: alertsOn ? colors.success : colors.warning,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bootstrapping ? '$subtitle…' : subtitle,
                    style: TextStyle(
                      height: 1.45,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
