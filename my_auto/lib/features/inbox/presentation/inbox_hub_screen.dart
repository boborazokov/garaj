import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/chat/presentation/screens/chats_screen.dart';
import 'package:my_auto/features/notifications/presentation/notifications_center_screen.dart';
import 'package:my_auto/features/notifications/bloc/notifications_bloc.dart';
import 'package:my_auto/features/notifications/bloc/notifications_event.dart';
import 'package:my_auto/features/notifications/bloc/notifications_state.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';

/// Single entry for chats + push / system notifications.
class InboxHubScreen extends StatefulWidget {
  const InboxHubScreen({super.key, this.initialTab = 0});

  /// 0 = messages, 1 = notifications
  final int initialTab;

  /// Legacy helper — opens messages or push on separate screens.
  static Future<void> open(BuildContext context, {int tab = 0}) async {
    if (tab == 1) {
      await NotificationsCenterScreen.open(context);
    } else {
      await ChatsScreen.open(context);
    }
  }

  @override
  State<InboxHubScreen> createState() => _InboxHubScreenState();
}

class _InboxHubScreenState extends State<InboxHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    final index = widget.initialTab.clamp(0, 1);
    _tabs = TabController(length: 2, vsync: this, initialIndex: index);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(
        title: s.messages,
        bottomHeight: 48,
        bottom: TabBar(
          controller: _tabs,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textMuted,
          indicatorColor: colors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.messageCircle, size: 18),
                  const SizedBox(width: 6),
                  Text(s.messages),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.bell, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      s.notificationsCenterTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          ChatsScreen(embedded: true),
          _NotificationsTab(),
        ],
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listenWhen: (p, c) => p.failureMessage != c.failureMessage,
      listener: (context, state) {
        final msg = state.failureMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      builder: (context, state) {
        final colors = context.appColors;
        final s = S.of(context);
        return RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            context
                .read<NotificationsBloc>()
                .add(const NotificationsBootstrapped());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.permissionGranted
                                ? LucideIcons.bell
                                : LucideIcons.bellOff,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.permissionGranted
                                  ? 'Push enabled'
                                  : 'Alerts paused',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.notificationsCenterEmptyBody,
                        style: TextStyle(
                          color: colors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.notificationsCenterFooterHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
