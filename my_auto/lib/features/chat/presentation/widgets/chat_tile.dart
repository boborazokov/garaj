import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';
import '../../domain/entities/conversation.dart';
import 'unread_badge.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.isSelected = false,
    this.onDelete,
  });

  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onDelete;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final peer = widget.conversation.peerFor(widget.currentUserId);
    final title = peer?.name ?? 'Chat';

    final lastText = widget.conversation.lastMessageText ?? '';
    final isMineLast =
        widget.conversation.lastMessageSenderId == widget.currentUserId;

    // Decode our backend's placeholder tokens into pretty UI hints.
    final (lastIcon, lastPreview) = _resolveLastMessageDisplay(
      text: lastText,
      s: s,
    );

    final isUnread = widget.conversation.unread > 0;
    final bg = widget.isSelected
        ? colors.primary.withValues(alpha: 0.1)
        : _hovered
            ? colors.surfaceMuted.withValues(alpha: 0.55)
            : colors.surface;

    return RepaintBoundary(
      child: Material(
        color: bg,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _Avatar(name: title, size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isUnread
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  fontSize: 16,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (widget.conversation.lastMessageAt != null)
                              Text(
                                _formatRelative(
                                    widget.conversation.lastMessageAt!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isUnread
                                      ? colors.primary
                                      : colors.textMuted,
                                  fontWeight: isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: widget.conversation.isPeerTyping
                                ? Text(
                                    s.chatHeaderTyping,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      if (isMineLast)
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional
                                                      .only(end: 4),
                                          child: Icon(
                                            LucideIcons.checkCheck,
                                            size: 14,
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      if (lastIcon != null)
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional
                                                      .only(end: 4),
                                          child: Icon(
                                            lastIcon,
                                            size: 14,
                                            color: colors.primary,
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          lastPreview,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isUnread
                                                ? colors.textPrimary
                                                : colors.textMuted,
                                            fontWeight: isUnread
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                            const SizedBox(width: 8),
                            if (_hovered && widget.onDelete != null)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: s.delete,
                                onPressed: widget.onDelete,
                                icon: Icon(
                                  LucideIcons.trash2,
                                  size: 16,
                                  color: colors.textMuted,
                                ),
                              )
                            else
                              UnreadBadge(count: widget.conversation.unread),
                          ],
                        ),
                        if (widget.conversation.partName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(LucideIcons.package,
                                  size: 12, color: colors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.conversation.partName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (IconData?, String) _resolveLastMessageDisplay({
    required String text,
    required S s,
  }) {
    final trimmed = text.trim();
    if (trimmed == '[photo]') return (LucideIcons.image, s.chatLastPhoto);
    if (trimmed == '[voice]') return (LucideIcons.mic, s.chatLastVoice);
    return (null, trimmed);
  }

  String _formatRelative(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (now.difference(dt).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}.${dt.month}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.size = 48});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initials = _initials(name);
    final color = _colorForName(name, colors);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: .9),
            color.withValues(alpha: .55),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _colorForName(String n, AppColors colors) {
    const palette = [
      Color(0xFF4F8AFC),
      Color(0xFFB766FF),
      Color(0xFF20BFAA),
      Color(0xFFFFA040),
      Color(0xFFE36F8B),
      Color(0xFF6BC36C),
      Color(0xFF6E7CFF),
    ];
    final h = n.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[h % palette.length];
  }
}
