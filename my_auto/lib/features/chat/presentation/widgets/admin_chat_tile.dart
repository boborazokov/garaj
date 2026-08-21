import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/chat/admin/admin_chat.dart';

import '../../domain/entities/conversation.dart';
import 'unread_badge.dart';

/// Pinned tile shown at the top of the chat list.
///
/// When [conversation] is null, the tile renders a static "say hi to admin"
/// shortcut — the conversation is created on first tap. When a real
/// conversation already exists, it mirrors `ChatTile` for the unread badge
/// and the last message preview, so the user can find the thread instantly.
class AdminChatTile extends StatelessWidget {
  const AdminChatTile({
    super.key,
    required this.onTap,
    this.conversation,
  });

  final VoidCallback onTap;
  final Conversation? conversation;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final strings = AdminChatStrings.of(context);
    final unread = conversation?.unread ?? 0;
    final lastText = conversation?.lastMessageText;
    final isTyping = conversation?.isPeerTyping == true;

    final subtitle = isTyping
        ? 'typing…'
        : (lastText?.trim().isNotEmpty == true
            ? lastText!
            : strings.pinnedSubtitle);

    return RepaintBoundary(
      child: Material(
        color: colors.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border, width: 0.5),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.primaryHover],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.shieldCheck,
                    color: colors.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              strings.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            LucideIcons.badgeCheck,
                            size: 16,
                            color: colors.primary,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PINNED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isTyping
                                    ? colors.primary
                                    : colors.textMuted,
                                fontStyle: isTyping
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontWeight: unread > 0 && !isTyping
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          UnreadBadge(count: unread),
                        ],
                      ),
                    ],
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
