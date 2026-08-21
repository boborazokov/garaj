import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';
import '../../bloc/chat_room/chat_room_bloc.dart';
import '../../bloc/chat_room/chat_room_event.dart';
import '../../bloc/chat_room/chat_room_state.dart';
import '../../domain/entities/chat_message.dart';
import '../../chat_di.dart' show chatRepository;
import '../widgets/chat_responsive.dart';
import '../widgets/connection_banner.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_composer.dart';
import '../../realtime/chat_realtime_recovery.dart';

class _PeerHeaderInsights {
  const _PeerHeaderInsights({
    required this.displayName,
    this.lastPeerMessageAt,
  });

  final String displayName;
  final DateTime? lastPeerMessageAt;
}

_PeerHeaderInsights _computePeerHeaderInsights(
  Iterable<ChatMessage> messages,
  String currentUserId,
  String fallbackTitle,
) {
  var peerId = '';
  DateTime? lastPeer;
  for (final m in messages) {
    if (m.senderId.isEmpty || m.senderId == currentUserId) continue;
    peerId = peerId.isEmpty ? m.senderId : peerId;
    if (m.senderId != peerId) continue;
    final at = m.createdAt;
    if (lastPeer == null || at.isAfter(lastPeer)) lastPeer = at;
  }

  var name = fallbackTitle;
  if (peerId.isNotEmpty) {
    for (final m in messages) {
      if (m.senderId != peerId) continue;
      final n = m.senderName.trim();
      if (n.isNotEmpty) {
        name = n;
        break;
      }
    }
  }
  return _PeerHeaderInsights(
    displayName: name,
    lastPeerMessageAt: lastPeer,
  );
}

String _chatRelativeTime(S s, DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return s.chatJustNow;
  if (diff.inHours < 1) return s.chatMinutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return s.chatHoursAgo(diff.inHours);
  return s.chatDaysAgo(diff.inDays);
}

String _peerHeaderFingerprint(
  List<ChatMessage> messages,
  String currentUserId,
  String fallbackTitle,
) {
  final i = _computePeerHeaderInsights(messages, currentUserId, fallbackTitle);
  final last = i.lastPeerMessageAt?.millisecondsSinceEpoch ?? -1;
  return '${i.displayName}|$last|${messages.length}';
}

bool _shouldRebuildChatAppBar(
  ChatRoomState previous,
  ChatRoomState current,
  String currentUserId,
  String fallbackTitle,
) {
  if (previous.isPeerTyping != current.isPeerTyping) return true;
  if (previous.status != current.status) return true;
  return _peerHeaderFingerprint(previous.messages, currentUserId, fallbackTitle) !=
      _peerHeaderFingerprint(current.messages, currentUserId, fallbackTitle);
}

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    this.peerTitle,
    this.prefillText,
    this.embedded = false,
  });

  final String conversationId;
  final String? peerTitle;

  /// One-shot composer draft. Used by entry points like "Request verification"
  /// to start the chat with a pre-typed message that the user can edit.
  final String? prefillText;

  /// True when rendered inside [ChatShellScreen] on wide layouts.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().auth;
    if (auth == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    final user = auth.user;

    return BlocProvider(
      create: (_) => ChatRoomBloc(
        repository: chatRepository,
        currentUserId: user.id,
        currentUserName: user.name,
      )..add(ChatRoomOpened(conversationId)),
      child: ChatRealtimeRecovery(
        enableChatsList: false,
        child: _ChatDetailView(
          conversationId: conversationId,
          currentUserId: user.id,
          peerTitle: peerTitle ?? S.of(context).chatConversationTitle,
          prefillText: prefillText,
          embedded: embedded,
        ),
      ),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  const _ChatDetailView({
    required this.conversationId,
    required this.currentUserId,
    required this.peerTitle,
    this.prefillText,
    this.embedded = false,
  });

  final String conversationId;
  final String currentUserId;
  final String peerTitle;
  final String? prefillText;
  final bool embedded;

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView>
    with WidgetsBindingObserver {
  Timer? _subtitleRefreshTimer;

  String? _peerId;
  String? _editingMessageId;
  String? _editingInitialText;
  ChatMessage? _replyingTo;

  void _startEditing(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _editingInitialText = message.text;
      _replyingTo = null;
    });
  }

  void _cancelEditing() {
    if (_editingMessageId == null) return;
    setState(() {
      _editingMessageId = null;
      _editingInitialText = null;
    });
  }

  void _startReplying(ChatMessage message) {
    setState(() {
      _replyingTo = message;
      _editingMessageId = null;
      _editingInitialText = null;
    });
  }

  void _cancelReplying() {
    if (_replyingTo == null) return;
    setState(() => _replyingTo = null);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subtitleRefreshTimer =
        Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subtitleRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed || !mounted) return;
    context.read<ChatRoomBloc>().add(const ChatRoomPrefetchLatest());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final userId = widget.currentUserId;
    final isWide = ChatResponsive.isWide(context);
    final useWebUx = kIsWeb || isWide;

    final chatBody = Column(
      children: [
        BlocSelector<ChatRoomBloc, ChatRoomState, bool>(
          selector: (s) => s.subscriptionAlive,
          builder: (context, alive) => ConnectionBanner(
            alive: alive,
            onRetry: alive
                ? null
                : () => context
                    .read<ChatRoomBloc>()
                    .add(const ChatRoomResubscribe()),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              border: isWide
                  ? null
                  : null,
            ),
            child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
              buildWhen: (p, c) =>
                  p.status != c.status ||
                  p.messages != c.messages ||
                  p.messages.length != c.messages.length ||
                  p.isPeerTyping != c.isPeerTyping ||
                  _lastReadFingerprint(p) != _lastReadFingerprint(c),
              builder: (context, state) {
                final peerId = _resolvePeerId(state);
                if (peerId != null && peerId != _peerId) {
                  _peerId = peerId;
                }
                return _MessageList(
                  state: state,
                  currentUserId: userId,
                  peerId: peerId,
                  editingMessageId: _editingMessageId,
                  isDesktop: useWebUx,
                  onDeleteMessage: (id) => context
                      .read<ChatRoomBloc>()
                      .add(ChatRoomDeleteMessageRequested(id)),
                  onStartEdit: _startEditing,
                  onReply: _startReplying,
                );
              },
            ),
          ),
        ),
        BlocSelector<ChatRoomBloc, ChatRoomState, bool>(
          selector: (s) => s.messages.any((m) => m.isSending),
          builder: (context, isSending) => MessageComposer(
            isSending: isSending,
            isDesktop: useWebUx,
            editingMessageId: _editingMessageId,
            editingInitialText: _editingInitialText,
            replyTo: _replyingTo,
            initialDraftText: widget.prefillText,
            onCancelEdit: _cancelEditing,
            onCancelReply: _cancelReplying,
            onSend: (payload) {
              context.read<ChatRoomBloc>().add(
                    ChatRoomSendRequested(
                      text: payload.text,
                      imagePaths: payload.imagePaths,
                      replyToMessageId: payload.replyToMessageId,
                      voicePath: payload.voicePath,
                      voiceDurationMs: payload.voiceDurationMs,
                    ),
                  );
              _cancelReplying();
            },
            onUpdate: (id, text) {
              context.read<ChatRoomBloc>().add(
                    ChatRoomEditMessageRequested(
                      messageId: id,
                      text: text,
                    ),
                  );
              _cancelEditing();
            },
            onTyping: (v) =>
                context.read<ChatRoomBloc>().add(ChatRoomTypingChanged(v)),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: true,
        appBar: _buildChatAppBar(context, userId, showBack: false),
        body: chatBody,
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      appBar: _buildChatAppBar(context, userId, showBack: true),
      body: chatBody,
    );
  }

  PreferredSizeWidget _buildChatAppBar(
    BuildContext context,
    String userId, {
    required bool showBack,
  }) {
    final colors = context.appColors;
    return AppBar(
        toolbarHeight: 72,
        centerTitle: false,
        automaticallyImplyLeading: showBack,
        title: BlocBuilder<ChatRoomBloc, ChatRoomState>(
          buildWhen: (p, c) => _shouldRebuildChatAppBar(
            p,
            c,
            userId,
            widget.peerTitle,
          ),
          builder: (context, state) {
            final s = S.of(context);
            final textTheme = Theme.of(context).textTheme;
            final insight = _computePeerHeaderInsights(
              state.messages,
              userId,
              widget.peerTitle,
            );

            final Widget subtitle;
            if (state.status == ChatRoomStatus.loading &&
                state.messages.isEmpty) {
              subtitle = SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textMuted,
                ),
              );
            } else if (state.isPeerTyping) {
              subtitle = Text(
                s.chatHeaderTyping,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.info,
                  fontWeight: FontWeight.w500,
                ),
              );
            } else if (insight.lastPeerMessageAt != null) {
              final lp = insight.lastPeerMessageAt!;
              final diff = DateTime.now().difference(lp);
              if (diff <= const Duration(minutes: 3)) {
                subtitle = Text(
                  s.chatPeerRecentlyActive,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                );
              } else {
                subtitle = Text(
                  s.chatPeerLastSeenInChat(_chatRelativeTime(s, lp)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                );
              }
            } else {
              subtitle = Text(
                s.chatPeerNoMessagesYet,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  insight.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                subtitle,
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Tooltip(
              message: S.of(context).chatHeaderInChatOnlyHint,
              child: Icon(
                Icons.info_outline,
                size: 22,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      );
  }

  String? _resolvePeerId(ChatRoomState state) {
    for (final m in state.messages) {
      if (m.senderId != widget.currentUserId && m.senderId.isNotEmpty) {
        return m.senderId;
      }
    }
    return null;
  }

  /// Fingerprint changes when readBy of any of *my* messages changes.
  /// Used to trigger a rebuild for read receipts without bloating
  /// `buildWhen` with deep diffs.
  String _lastReadFingerprint(ChatRoomState s) {
    final buf = StringBuffer();
    for (final m in s.messages) {
      if (m.senderId == widget.currentUserId) {
        buf
          ..write(m.id)
          ..write(':')
          ..write(m.readBy.length)
          ..write('|');
      }
    }
    return buf.toString();
  }
}

class _MessageList extends StatefulWidget {
  const _MessageList({
    required this.state,
    required this.currentUserId,
    required this.peerId,
    required this.editingMessageId,
    required this.isDesktop,
    required this.onDeleteMessage,
    required this.onStartEdit,
    required this.onReply,
  });

  final ChatRoomState state;
  final String currentUserId;
  final String? peerId;
  final String? editingMessageId;
  final bool isDesktop;
  final void Function(String messageId) onDeleteMessage;
  final void Function(ChatMessage message) onStartEdit;
  final void Function(ChatMessage message) onReply;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  final ScrollController _scrollController = ScrollController();
  String? _highlightedMessageId;
  Timer? _highlightTimer;

  GlobalKey _keyFor(String id) =>
      _messageKeys.putIfAbsent(id, () => GlobalKey(debugLabel: 'msg-$id'));

  Future<void> _jumpToMessage(String messageId) async {
    final exists = widget.state.messages.any((m) => m.id == messageId);
    if (!exists) {
      if (!mounted) return;
      context.read<ChatRoomBloc>().add(const ChatRoomLoadMore());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(S.of(context).chatOriginalMessageNotLoaded),
        ),
      );
      return;
    }

    if (!kIsWeb) HapticFeedback.selectionClick();

    for (var attempt = 0; attempt < 4; attempt++) {
      if (!mounted) return;
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 40 * attempt));
      }
      final ctx = _keyFor(messageId).currentContext;
      if (ctx == null) continue;
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
      break;
    }

    if (!mounted) return;
    setState(() => _highlightedMessageId = messageId);
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _highlightedMessageId = null);
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = widget.state;
    final currentUserId = widget.currentUserId;
    final peerId = widget.peerId;
    final editingMessageId = widget.editingMessageId;
    final onStartEdit = widget.onStartEdit;
    final onReply = widget.onReply;

    switch (state.status) {
      case ChatRoomStatus.loading:
        return const Center(child: CircularProgressIndicator.adaptive());
      case ChatRoomStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.alertCircle, color: colors.danger, size: 40),
              const SizedBox(height: 12),
              Text(
                GraphqlErrorUi.localizeRaw(context, state.failure?.message),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context
                    .read<ChatRoomBloc>()
                    .add(ChatRoomOpened(state.conversationId)),
                child: Text(S.of(context).createProductRetry),
              ),
            ],
          ),
        );
      case ChatRoomStatus.empty:
        return Center(
          child: Text(
            S.of(context).chatSayHello,
            style: TextStyle(color: colors.textMuted),
          ),
        );
      case ChatRoomStatus.success:
      case ChatRoomStatus.loadingMore:
        final list = NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
              context.read<ChatRoomBloc>().add(const ChatRoomLoadMore());
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: widget.isDesktop ? 24 : 0,
            ),
            itemCount: state.messages.length +
                (state.status == ChatRoomStatus.loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.messages.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
              final m = state.messages[index];
              final isMine = m.senderId == currentUserId;
              return MessageBubble(
                key: _keyFor(m.id),
                message: m,
                isMine: isMine,
                isDesktop: widget.isDesktop,
                isEditing: m.id == editingMessageId,
                isHighlighted: _highlightedMessageId == m.id,
                peerId: peerId,
                onRetry: m.clientTempId != null
                    ? () => context.read<ChatRoomBloc>().add(
                          ChatRoomRetrySend(m.clientTempId!),
                        )
                    : null,
                onEdit: isMine && !m.hasImages && !m.hasVoice && !m.isSending
                    ? () => onStartEdit(m)
                    : null,
                onDelete: isMine
                    ? () => _confirmDeleteMessage(context, m)
                    : null,
                onReply: m.isSending ? null : () => onReply(m),
                onReplyTap: _jumpToMessage,
                onCopy: m.hasText
                    ? () async {
                        await Clipboard.setData(
                          ClipboardData(text: m.text),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).chatCopied),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    : null,
              );
            },
          ),
        );

        if (!widget.isDesktop && !kIsWeb) return list;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ChatResponsive.messageColumnMaxWidth,
            ),
            child: list,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmDeleteMessage(
    BuildContext context,
    ChatMessage message,
  ) async {
    final s = S.of(context);
    final colors = context.appColors;
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
            child: Text(s.delete, style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.onDeleteMessage(message.id);
  }
}
