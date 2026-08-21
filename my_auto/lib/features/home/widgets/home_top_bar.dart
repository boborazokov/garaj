import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/presentation/screens/chats_screen.dart';
import 'package:my_auto/features/notifications/bloc/notifications_bloc.dart';
import 'package:my_auto/features/notifications/bloc/notifications_state.dart';
import 'package:my_auto/features/notifications/presentation/notifications_center_screen.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart' show pushService;
import 'package:my_auto/widgets/buttom_navigation_bar/index.dart';

/// Home header: tappable app brand (→ profile), messages, notifications.
class HomeTopBar extends StatefulWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  int _chatUnread = 0;
  late final TextEditingController _searchController;
  StreamSubscription<({String conversationId, int unread})>? _unreadSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncUnread());
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _syncUnread() {
    _unreadSub?.cancel();
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      if (mounted) setState(() => _chatUnread = 0);
      return;
    }
    unawaited(_loadUnread());
    _unreadSub = chatRepository.watchUnreadCounts().listen((_) {
      if (mounted) unawaited(_loadUnread());
    });
  }

  void _openSearch() {
    context.push(
      RoutesName.search,
      extra: const {'isAllProduct': true, 'unifiedSearch': true},
    );
  }

  Future<void> _loadUnread() async {
    if (!context.read<AuthProvider>().isAuthenticated) return;
    try {
      final result = await chatRepository.getConversations(limit: 20);
      if (!mounted) return;
      setState(() {
        _chatUnread = result.items.fold<int>(0, (s, c) => s + c.unread);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final colors = context.appColors;
    final s = S.of(context);
    final hasUnreadMessages = _chatUnread > 0;

    if (auth.isGuest && _unreadSub != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncUnread());
    } else if (auth.isAuthenticated && _unreadSub == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncUnread());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: colors.surface,
              borderRadius: AppRadius.rL,
              child: InkWell(
                borderRadius: AppRadius.rL,
                onTap: _openSearch,
                child: IgnorePointer(
                  child: TextField(
                    controller: _searchController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: s.search,
                      hintStyle: TextStyle(color: colors.textMuted),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 20,
                        color: colors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          _HeaderActions(
            hasUnreadMessages: hasUnreadMessages,
            chatUnread: _chatUnread,
            onMessages: () => ChatsScreen.open(context),
            onNotifications: () => NotificationsCenterScreen.open(context),
          ),
        ],
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.hasUnreadMessages,
    required this.chatUnread,
    required this.onMessages,
    required this.onNotifications,
  });

  final bool hasUnreadMessages;
  final int chatUnread;
  final VoidCallback onMessages;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderIconButton(
            tooltip: s.messages,
            onPressed: onMessages,
            icon: LucideIcons.messageCircle,
            iconColor: hasUnreadMessages ? colors.danger : colors.textPrimary,
            badge: hasUnreadMessages
                ? _TopBarBadge(
                    label: chatUnread > 9 ? '9+' : '$chatUnread',
                    color: colors.danger,
                  )
                : null,
          ),
          if (pushService.operational)
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, nState) {
                final pushWarn = nState.status == NotificationsStatus.denied ||
                    (!nState.permissionGranted &&
                        nState.status != NotificationsStatus.bootstrapping);
                return _HeaderIconButton(
                  tooltip: s.notificationsCenterTitle,
                  onPressed: onNotifications,
                  customIcon: SvgPicture.asset(
                    'assets/svg/notification.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      colors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  badge: pushWarn
                      ? Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: colors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 1.5,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.customIcon,
    this.iconColor,
    this.badge,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          if (customIcon != null)
            customIcon!
          else
            Icon(
              icon,
              color: iconColor ?? colors.textPrimary,
              size: 22,
            ),
          if (badge != null)
            Positioned(
              right: -2,
              top: -2,
              child: badge!,
            ),
        ],
      ),
    );
  }
}

class _TopBarBadge extends StatelessWidget {
  const _TopBarBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
