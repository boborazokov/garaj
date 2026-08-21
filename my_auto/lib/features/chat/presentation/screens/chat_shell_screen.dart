import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';

import '../widgets/chat_responsive.dart';
import 'chat_detail_screen.dart';
import 'chats_screen.dart';

/// Master-detail chat shell for wide screens (web/desktop).
/// On narrow screens behaves like separate list / detail routes.
class ChatShellScreen extends StatelessWidget {
  const ChatShellScreen({
    super.key,
    this.conversationId,
    this.peerTitle,
    this.prefillText,
  });

  final String? conversationId;
  final String? peerTitle;
  final String? prefillText;

  void _openConversation(
    BuildContext context, {
    required String id,
    String? title,
  }) {
    context.go(
      '${RoutesName.chatDetail}/$id',
      extra: title == null ? null : {'peerTitle': title},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ChatResponsive.isWide(context);

    if (!isWide) {
      if (conversationId != null) {
        return ChatDetailScreen(
          conversationId: conversationId!,
          peerTitle: peerTitle,
          prefillText: prefillText,
        );
      }
      return const ChatsScreen();
    }

    final colors = context.appColors;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          SizedBox(
            width: ChatResponsive.sidebarWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  right: BorderSide(color: colors.border),
                ),
              ),
              child: ChatsScreen(
                embedded: true,
                selectedConversationId: conversationId,
                onSelectConversation: (id, title) => _openConversation(
                  context,
                  id: id,
                  title: title,
                ),
              ),
            ),
          ),
          Expanded(
            child: conversationId == null
                ? _ChatEmptyPane(s: s, colors: colors)
                : ChatDetailScreen(
                    conversationId: conversationId!,
                    peerTitle: peerTitle,
                    prefillText: prefillText,
                    embedded: true,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatEmptyPane extends StatelessWidget {
  const _ChatEmptyPane({required this.s, required this.colors});

  final S s;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  LucideIcons.messageSquare,
                  size: 32,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                s.chatSelectConversation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.chatSelectConversationHint,
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
    );
  }
}
