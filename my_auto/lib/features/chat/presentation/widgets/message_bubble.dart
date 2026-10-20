import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/local_image.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_responsive.dart';
import 'voice_message_player.dart';

/// Telegram-style chat bubble:
///  - swipe right (or left, for "my" bubbles) to start a reply
///  - tappable quote at the top when the message replies to another one
///  - photo grid for images, native player for voice
///  - long-press to reveal reply / edit / delete actions
class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.isEditing = false,
    this.isHighlighted = false,
    this.isDesktop = false,
    this.peerId,
    this.onRetry,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.onCopy,
    this.onReplyTap,
  });

  final ChatMessage message;
  final bool isMine;
  final bool isEditing;
  final bool isHighlighted;
  final bool isDesktop;

  final String? peerId;
  final VoidCallback? onRetry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final VoidCallback? onCopy;

  /// Called when the user taps the quoted reply preview to jump to the
  /// original message it references.
  final void Function(String messageId)? onReplyTap;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  static const double _swipeThreshold = 56;

  double _dragX = 0;
  bool _replyTriggered = false;
  bool _hovered = false;

  bool get _useWebUx => kIsWeb || widget.isDesktop;

  void _onUpdate(DragUpdateDetails d) {
    if (_useWebUx || widget.onReply == null) return;
    // Drag right reveals reply; allow tiny left drag too for "my" bubbles.
    final delta = d.delta.dx;
    setState(() {
      _dragX = (_dragX + delta).clamp(-_swipeThreshold, _swipeThreshold);
    });
    if (!_replyTriggered && _dragX.abs() >= _swipeThreshold) {
      _replyTriggered = true;
      if (!kIsWeb) HapticFeedback.lightImpact();
    }
  }

  void _onEnd(DragEndDetails _) {
    if (_replyTriggered && widget.onReply != null) {
      widget.onReply!();
    }
    setState(() {
      _dragX = 0;
      _replyTriggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = widget.isEditing
        ? (widget.isMine
            ? colors.primary.withValues(alpha: 0.78)
            : colors.surfaceMuted.withValues(alpha: 0.9))
        : (widget.isMine ? colors.primary : colors.surfaceMuted);
    final textFg = widget.isMine ? colors.onPrimary : colors.textPrimary;

    final bubbleMaxW = ChatResponsive.bubbleMaxWidth(context);
    final swipeIndicatorOpacity = _useWebUx
        ? 0.0
        : (_dragX.abs() / _swipeThreshold).clamp(0.0, 1.0) * .9;

    final showWebActions = _useWebUx &&
        _hovered &&
        !widget.message.isSending &&
        (widget.onReply != null ||
            widget.onDelete != null ||
            widget.onEdit != null ||
            (widget.onCopy != null && widget.message.hasText));

    final bubbleColumn = Column(
      crossAxisAlignment: widget.isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: bubbleMaxW),
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(widget.isMine ? 18 : 4),
                  bottomRight: Radius.circular(widget.isMine ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.message.replyTo != null)
                    _ReplyQuote(
                      snapshot: widget.message.replyTo!,
                      isMine: widget.isMine,
                      onTap: widget.onReplyTap == null
                          ? null
                          : () => widget.onReplyTap!(
                                widget.message.replyTo!.messageId,
                              ),
                    ),
                  if (widget.message.hasImages)
                    _ImageGrid(images: widget.message.images),
                  if (widget.message.hasVoice)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                      child: VoiceMessagePlayer(
                        source: _resolveAudioSource(
                          widget.message.voiceUrl!,
                        ),
                        durationMs: widget.message.voiceDurationMs,
                        isMine: widget.isMine,
                      ),
                    ),
                  if (widget.message.hasText)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                      child: Text(
                        widget.message.text,
                        style: TextStyle(
                          color: textFg,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                    )
                  else if (widget.message.hasImages ||
                      widget.message.hasVoice)
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(widget.message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: colors.textMuted,
              ),
            ),
            if (widget.isMine) ...[
              const SizedBox(width: 6),
              _StatusIcon(
                message: widget.message,
                peerId: widget.peerId,
                onRetry: widget.onRetry,
              ),
            ],
          ],
        ),
      ],
    );

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: widget.isHighlighted
            ? colors.primary.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: widget.isHighlighted
            ? Border.all(color: colors.primary.withValues(alpha: 0.35))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: widget.isMine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        children: [
          if (swipeIndicatorOpacity > 0)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Opacity(
                opacity: swipeIndicatorOpacity,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: .15),
                  ),
                  child: Icon(
                    LucideIcons.cornerUpLeft,
                    color: colors.primary,
                    size: 16,
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_useWebUx ? 0 : _dragX, 0),
            child: Align(
              alignment: widget.isMine
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: bubbleColumn,
            ),
          ),
        ],
      ),
    );

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: _useWebUx ? (_) => setState(() => _hovered = true) : null,
        onExit: _useWebUx ? (_) => setState(() => _hovered = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _useWebUx ? null : _onUpdate,
          onHorizontalDragEnd: _useWebUx ? null : _onEnd,
          onLongPress: _useWebUx ? null : () => _showActions(context),
          onSecondaryTapUp: _useWebUx
              ? (d) => _showActions(context, d.globalPosition)
              : null,
          child: Column(
            crossAxisAlignment: widget.isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (showWebActions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _WebMessageActionBar(
                    isMine: widget.isMine,
                    onReply: widget.onReply,
                    onDelete: widget.onDelete,
                    onEdit: widget.onEdit,
                    onCopy: widget.message.hasText ? widget.onCopy : null,
                    onMore: () => _showActions(context),
                  ),
                ),
              content,
            ],
          ),
        ),
      ),
    );
  }

  String _resolveAudioSource(String src) {
    if (src.startsWith('http')) return src;
    // Optimistic outbox value: a real on-device path while the upload
    // is still in flight.
    if (isLocalImagePath(src)) return src;
    final resolved = resolveMediaUrl(src, mediaBase: fileUrl);
    return resolved ?? src;
  }

  void _showActions(BuildContext context, [Offset? globalPosition]) {
    final colors = context.appColors;
    final s = S.of(context);

    void run(VoidCallback? action) {
      if (action != null) action();
    }

    final items = <PopupMenuEntry<VoidCallback>>[
      if (widget.onReply != null)
        PopupMenuItem(
          value: widget.onReply,
          child: Row(
            children: [
              Icon(LucideIcons.cornerUpLeft, size: 18, color: colors.textPrimary),
              const SizedBox(width: 10),
              Text(s.chatReply),
            ],
          ),
        ),
      if (widget.onCopy != null && widget.message.hasText)
        PopupMenuItem(
          value: widget.onCopy,
          child: Row(
            children: [
              Icon(LucideIcons.copy, size: 18, color: colors.textPrimary),
              const SizedBox(width: 10),
              Text(s.chatCopy),
            ],
          ),
        ),
      if (!widget.message.hasImages &&
          !widget.message.hasVoice &&
          widget.onEdit != null)
        PopupMenuItem(
          value: widget.onEdit,
          child: Row(
            children: [
              Icon(LucideIcons.pencil, size: 18, color: colors.textPrimary),
              const SizedBox(width: 10),
              Text(s.edit),
            ],
          ),
        ),
      if (widget.onDelete != null)
        PopupMenuItem(
          value: widget.onDelete,
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 18, color: colors.danger),
              const SizedBox(width: 10),
              Text(s.delete, style: TextStyle(color: colors.danger)),
            ],
          ),
        ),
    ];

    if (items.isEmpty) return;

    if (_useWebUx) {
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final position = globalPosition ?? overlay.size.center(Offset.zero);
      final rect = RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      );
      showMenu<VoidCallback>(
        context: context,
        position: rect,
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        items: items,
      ).then((action) => run(action));
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => AppSafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onReply != null)
              ListTile(
                leading: Icon(LucideIcons.cornerUpLeft,
                    color: colors.textPrimary),
                title: Text(s.chatReply),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onReply!();
                },
              ),
            if (widget.onCopy != null && widget.message.hasText)
              ListTile(
                leading: Icon(LucideIcons.copy, color: colors.textPrimary),
                title: Text(s.chatCopy),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onCopy!();
                },
              ),
            if (!widget.message.hasImages &&
                !widget.message.hasVoice &&
                widget.onEdit != null)
              ListTile(
                leading: Icon(LucideIcons.pencil, color: colors.textPrimary),
                title: Text(s.edit),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onEdit!();
                },
              ),
            if (widget.onDelete != null)
              ListTile(
                leading: Icon(LucideIcons.trash2, color: colors.danger),
                title: Text(
                  s.delete,
                  style: TextStyle(color: colors.danger),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _WebMessageActionBar extends StatelessWidget {
  const _WebMessageActionBar({
    required this.isMine,
    this.onReply,
    this.onDelete,
    this.onEdit,
    this.onCopy,
    this.onMore,
  });

  final bool isMine;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Material(
      elevation: 1,
      shadowColor: colors.shadow.withValues(alpha: 0.12),
      color: colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReply != null)
              _WebActionChip(
                icon: LucideIcons.cornerUpLeft,
                label: s.chatReply,
                onTap: onReply!,
              ),
            if (onCopy != null)
              _WebActionChip(
                icon: LucideIcons.copy,
                label: s.chatCopy,
                onTap: onCopy!,
              ),
            if (isMine && onEdit != null)
              _WebActionChip(
                icon: LucideIcons.pencil,
                label: s.edit,
                onTap: onEdit!,
              ),
            if (isMine && onDelete != null)
              _WebActionChip(
                icon: LucideIcons.trash2,
                label: s.delete,
                danger: true,
                onTap: onDelete!,
              ),
            if (onMore != null)
              _WebActionChip(
                icon: LucideIcons.moreHorizontal,
                label: s.more,
                onTap: onMore!,
              ),
          ],
        ),
      ),
    );
  }
}

class _WebActionChip extends StatelessWidget {
  const _WebActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = danger ? colors.danger : colors.textPrimary;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Icon(icon, size: 16, color: fg),
        ),
      ),
    );
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({
    required this.snapshot,
    required this.isMine,
    this.onTap,
  });

  final ChatReplySnapshot snapshot;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bar = isMine ? colors.onPrimary : colors.primary;
    final muted = isMine
        ? colors.onPrimary.withValues(alpha: .75)
        : colors.textMuted;

    final card = Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: (isMine ? colors.onPrimary : colors.primary)
            .withValues(alpha: .08),
        borderRadius: AppRadius.rS,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: bar),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snapshot.senderName?.trim().isNotEmpty == true
                        ? snapshot.senderName!
                        : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: bar,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  if ((snapshot.text ?? '').isNotEmpty)
                    Text(
                      snapshot.text!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: onTap == null
          ? card
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  onTap: onTap,
                  hoverColor: (isMine ? colors.onPrimary : colors.primary)
                      .withValues(alpha: 0.06),
                  child: card,
                ),
              ),
            ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images});
  final List<String> images;

  void _openGallery(BuildContext context, int index) {
    context.push(
      RoutesName.fullScreenGallery,
      extra: {
        'images': images,
        'initialIndex': index,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.7;
    final clampedW = width.clamp(140.0, 280.0);

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: GestureDetector(
          onTap: () => _openGallery(context, 0),
          child: _ChatImage(
            source: images.first,
            width: clampedW,
            height: clampedW * 0.75,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: SizedBox(
        width: clampedW,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: images.length > 4 ? 4 : images.length,
          itemBuilder: (_, i) {
            final last = i == 3 && images.length > 4;
            return GestureDetector(
              onTap: () => _openGallery(context, i),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ChatImage(source: images[i]),
                  if (last)
                    ColoredBox(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          '+${images.length - 4}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatImage extends StatelessWidget {
  const _ChatImage({required this.source, this.width, this.height});

  final String source;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // Remote = absolute http(s) URL OR a server-relative storage key
    // (e.g. "chats/images/abc.jpg"). Local-only paths come from the
    // optimistic outbox before the upload finishes and look like
    // "/data/...", "C:\..." or "file://...".
    final isLocal = isLocalImagePath(source);
    if (isLocal) {
      return localImage(
        source,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
    }
    return ImageCacheNetwork(
      url: source,
      width: width ?? double.infinity,
      height: height ?? 200,
      fit: BoxFit.cover,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.message,
    required this.peerId,
    this.onRetry,
  });

  final ChatMessage message;
  final String? peerId;
  final VoidCallback? onRetry;

  bool get _isReadByPeer {
    if (peerId == null) return false;
    return message.readBy.contains(peerId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (message.isFailed) {
      return GestureDetector(
        onTap: onRetry,
        child: Icon(LucideIcons.refreshCw, size: 14, color: colors.danger),
      );
    }
    if (message.isSending) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: colors.textMuted,
        ),
      );
    }
    if (_isReadByPeer) {
      return Icon(LucideIcons.checkCheck, size: 14, color: colors.info);
    }
    return Icon(LucideIcons.check, size: 14, color: colors.textMuted);
  }
}
