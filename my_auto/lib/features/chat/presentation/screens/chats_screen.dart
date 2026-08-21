import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/config/admin_config.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/chat/admin/admin_chat.dart';
import 'package:my_auto/generated/l10n.dart';
import '../../bloc/chats_list/chats_list_bloc.dart';
import '../../bloc/chats_list/chats_list_event.dart';
import '../../bloc/chats_list/chats_list_state.dart';
import '../../chat_di.dart';
import '../../domain/entities/conversation.dart';
import 'guest_chats_placeholder.dart';
import '../widgets/admin_chat_tile.dart';
import '../widgets/chat_tile.dart';
import '../widgets/connection_banner.dart';
import '../../realtime/chat_realtime_recovery.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({
    super.key,
    this.embedded = false,
    this.selectedConversationId,
    this.onSelectConversation,
  });

  final bool embedded;
  final String? selectedConversationId;

  /// When set (wide layout), tapping a conversation calls this instead of
  /// pushing a new route.
  final void Function(String conversationId, String? peerTitle)?
      onSelectConversation;

  static Future<void> open(BuildContext context) async {
    final ok = await AuthGuard.requireAuth(
      context,
      pending: const PendingRoute(path: RoutesName.chats),
    );
    if (!context.mounted || !ok) return;
    if (AuthGuard.isAuthenticated(context)) {
      context.push(RoutesName.chats);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().auth;
    if (auth == null) {
      return GuestChatsPlaceholder(embedded: embedded);
    }
    final userId = auth.user.id;
    return BlocProvider(
      create: (_) => ChatsListBloc(
        repository: chatRepository,
        currentUserId: userId,
      )..add(const ChatsListStarted()),
      child: ChatRealtimeRecovery(
        enableChatRoom: false,
        child: _ChatsView(
          embedded: embedded,
          selectedConversationId: selectedConversationId,
          onSelectConversation: onSelectConversation,
        ),
      ),
    );
  }
}

class _ChatsView extends StatelessWidget {
  const _ChatsView({
    required this.embedded,
    this.selectedConversationId,
    this.onSelectConversation,
  });

  final bool embedded;
  final String? selectedConversationId;
  final void Function(String conversationId, String? peerTitle)?
      onSelectConversation;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final body = BlocBuilder<ChatsListBloc, ChatsListState>(
      buildWhen: (p, c) =>
          p.status != c.status ||
          p.conversations.length != c.conversations.length ||
          p.subscriptionAlive != c.subscriptionAlive ||
          p.totalUnread != c.totalUnread,
      builder: (context, state) {
        return Column(
          children: [
            BlocSelector<ChatsListBloc, ChatsListState, bool>(
              selector: (s) => s.subscriptionAlive,
              builder: (context, alive) => ConnectionBanner(alive: alive),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );

    if (embedded) {
      return AppSafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                s.messages,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.messages),
        centerTitle: false,
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context, ChatsListState state) {
    final colors = context.appColors;
    final userId = context.read<AuthProvider>().auth!.user.id;

    final adminAvailable = AdminChat.isAvailable;
    final adminId = AdminConfig.userId;
    Conversation? adminConversation;
    if (adminAvailable) {
      for (final c in state.conversations) {
        if (c.participants.any((p) => p.id == adminId)) {
          adminConversation = c;
          break;
        }
      }
    }
    final regularConversations = adminConversation == null
        ? state.conversations
        : state.conversations
            .where((c) => c.id != adminConversation!.id)
            .toList(growable: false);

    Widget? adminTile;
    if (adminAvailable) {
      adminTile = AdminChatTile(
        conversation: adminConversation,
        onTap: () => AdminChat.open(context),
      );
    }

    switch (state.status) {
      case ChatsListStatus.loading:
        return const Center(child: CircularProgressIndicator.adaptive());
      case ChatsListStatus.empty:
        return Column(
          children: [
            if (adminTile != null) adminTile,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.messageCircle,
                        size: 48, color: colors.textMuted),
                    const SizedBox(height: 12),
                    Text(S.of(context).chatNoConversationsYet,
                        style: TextStyle(color: colors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        );
      case ChatsListStatus.error:
        return Column(
          children: [
            if (adminTile != null) adminTile,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      GraphqlErrorUi.localizeRaw(
                          context, state.failure?.message),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<ChatsListBloc>()
                          .add(const ChatsListRefreshed()),
                      child: Text(S.of(context).createProductRetry),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case ChatsListStatus.success:
      case ChatsListStatus.loadingMore:
        return RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            context.read<ChatsListBloc>().add(const ChatsListRefreshed());
            await context.read<ChatsListBloc>().stream.firstWhere(
                  (s) =>
                      s.status == ChatsListStatus.success ||
                      s.status == ChatsListStatus.empty ||
                      s.status == ChatsListStatus.error,
                );
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                context.read<ChatsListBloc>().add(const ChatsListLoadMore());
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: embedded ? 108 : 24),
              itemCount: (adminTile != null ? 1 : 0) +
                  regularConversations.length +
                  (state.status == ChatsListStatus.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (adminTile != null && index == 0) {
                  return adminTile;
                }
                final adjusted = adminTile != null ? index - 1 : index;
                if (adjusted >= regularConversations.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                final c = regularConversations[adjusted];
                final peer = c.peerFor(userId);
                final peerTitle = peer?.name;
                final tile = ChatTile(
                  conversation: c,
                  currentUserId: userId,
                  isSelected: c.id == selectedConversationId,
                  onTap: () {
                    final select = onSelectConversation;
                    if (select != null) {
                      select(c.id, peerTitle);
                      return;
                    }
                    context.push(
                      '${RoutesName.chatDetail}/${c.id}',
                      extra: peerTitle,
                    );
                  },
                  onDelete: () async {
                    final ok = await _confirmDeleteConversation(context);
                    if (ok && context.mounted) {
                      context
                          .read<ChatsListBloc>()
                          .add(ChatsListDeleteRequested(c.id));
                    }
                  },
                );
                if (onSelectConversation != null) return tile;
                return Dismissible(
                  key: ValueKey(c.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: colors.danger,
                    child: Icon(
                      LucideIcons.trash2,
                      color: colors.onPrimary,
                    ),
                  ),
                  confirmDismiss: (_) => _confirmDeleteConversation(context),
                  onDismissed: (_) => context
                      .read<ChatsListBloc>()
                      .add(ChatsListDeleteRequested(c.id)),
                  child: tile,
                );
              },
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<bool> _confirmDeleteConversation(BuildContext context) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.delete),
        content: Text(s.areYouSureToDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.delete,
              style: TextStyle(color: ctx.appColors.danger),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
