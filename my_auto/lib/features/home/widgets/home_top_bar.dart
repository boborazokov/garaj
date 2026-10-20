import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/presentation/screens/chats_screen.dart';
import 'package:my_auto/features/notifications/bloc/notifications_bloc.dart';
import 'package:my_auto/features/notifications/bloc/notifications_state.dart';
import 'package:my_auto/features/notifications/presentation/notifications_center_screen.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart' show pushService;
import 'package:my_auto/widgets/searchInput/index.dart';

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
            child: GestureDetector(
              onTap: _openSearch,
              behavior: HitTestBehavior.opaque,
              child: AbsorbPointer(
                child: CustomSearchInput(
                  controller: _searchController,
                  hintText: s.search,
                  readOnly: true,
                  showClear: false,
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleHeaderButton(
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
        if (pushService.operational) ...[
          const SizedBox(width: 8),
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, nState) {
              final pushWarn = nState.status == NotificationsStatus.denied ||
                  (!nState.permissionGranted &&
                      nState.status != NotificationsStatus.bootstrapping);
              return _CircleHeaderButton(
                tooltip: s.notificationsCenterTitle,
                onPressed: onNotifications,
                customIcon: SvgPicture.asset(
                  'assets/svg/notification.svg',
                  width: 20,
                  height: 20,
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
      ],
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  const _CircleHeaderButton({
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

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.border.withValues(alpha: 0.55),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (customIcon != null)
                  customIcon!
                else
                  Icon(
                    icon,
                    color: iconColor ?? colors.textPrimary,
                    size: 20,
                  ),
                if (badge != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: badge!,
                  ),
              ],
            ),
          ),
        ),
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
