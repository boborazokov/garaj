import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/file_io.dart';
import 'package:my_auto/core/utils/local_image.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../domain/entities/chat_message.dart';
import 'chat_responsive.dart';

class MessageComposerSendPayload {
  const MessageComposerSendPayload({
    required this.text,
    this.imagePaths = const [],
    this.replyToMessageId,
    this.voicePath,
    this.voiceDurationMs,
  });

  final String text;
  final List<String> imagePaths;
  final String? replyToMessageId;
  final String? voicePath;
  final int? voiceDurationMs;

  bool get isEmpty =>
      text.isEmpty &&
      imagePaths.isEmpty &&
      (voicePath == null || voicePath!.isEmpty);
}

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSend,
    this.onUpdate,
    this.onTyping,
    this.onCancelEdit,
    this.onCancelReply,
    this.isSending = false,
    this.isDesktop = false,
    this.editingMessageId,
    this.editingInitialText,
    this.replyTo,
    this.initialDraftText,
  });

  final void Function(MessageComposerSendPayload payload) onSend;
  final void Function(String messageId, String text)? onUpdate;
  final ValueChanged<bool>? onTyping;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onCancelReply;
  final bool isSending;
  final bool isDesktop;
  final String? editingMessageId;
  final String? editingInitialText;
  final ChatMessage? replyTo;

  /// Applied exactly once when the composer mounts. Lets entry points like
  /// "Request verification" pre-type a message that the user can edit.
  /// Ignored on subsequent rebuilds so we never overwrite live input.
  final String? initialDraftText;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _recorder = AudioRecorder();
  final _picker = ImagePicker();

  bool _isTyping = false;
  bool _hasText = false;
  String? _activeEditId;
  List<String> _pendingImagePaths = const [];

  // Voice
  bool _recording = false;
  bool _cancelArmed = false;
  DateTime? _recordStart;
  Timer? _ticker;
  Duration _recordedElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _syncEditMode();
    final draft = widget.initialDraftText;
    if (draft != null && draft.trim().isNotEmpty) {
      _controller.value = TextEditingValue(
        text: draft,
        selection: TextSelection.collapsed(offset: draft.length),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        _hasText = hasText;
        if (mounted) setState(() {});
      }
      _setTyping(hasText);
    });
  }

  @override
  void didUpdateWidget(MessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingMessageId != oldWidget.editingMessageId ||
        widget.editingInitialText != oldWidget.editingInitialText) {
      _syncEditMode();
    }
  }

  void _syncEditMode() {
    final editId = widget.editingMessageId;
    if (editId == null) {
      if (_activeEditId != null) {
        _activeEditId = null;
        _controller.clear();
        _setTyping(false);
      }
      return;
    }
    if (_activeEditId == editId) return;
    _activeEditId = editId;
    final text = widget.editingInitialText ?? '';
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _setTyping(false);
    _ticker?.cancel();
    _recorder.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setTyping(bool value) {
    if (_isTyping == value) return;
    _isTyping = value;
    widget.onTyping?.call(value);
  }

  void _cancelEdit() {
    _activeEditId = null;
    _controller.clear();
    _setTyping(false);
    widget.onCancelEdit?.call();
  }

  // -------------- Attachments --------------
  Future<void> _pickPhotos() async {
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (files.isEmpty) return;
      setState(() {
        _pendingImagePaths = [
          ..._pendingImagePaths,
          ...files.map((f) => f.path),
        ].take(10).toList();
      });
    } catch (_) {}
  }

  Future<void> _takePhoto() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (shot == null) return;
      setState(() {
        _pendingImagePaths = [..._pendingImagePaths, shot.path]
            .take(10)
            .toList();
      });
    } catch (_) {}
  }

  void _removeImage(int i) {
    setState(() {
      final next = [..._pendingImagePaths];
      next.removeAt(i);
      _pendingImagePaths = next;
    });
  }

  // -------------- Voice recording --------------
  Future<void> _startRecording() async {
    if (_recording) return;
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).chatMicPermissionRequired)),
        );
      }
      return;
    }
    // On web `path` is ignored by record_web (it returns a blob URL on stop);
    // on native we need a writable temp file.
    String path = '';
    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 96000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    HapticFeedback.mediumImpact();
    setState(() {
      _recording = true;
      _cancelArmed = false;
      _recordStart = DateTime.now();
      _recordedElapsed = Duration.zero;
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || _recordStart == null) return;
      setState(() => _recordedElapsed =
          DateTime.now().difference(_recordStart!));
    });
  }

  Future<void> _finishRecording({required bool cancel}) async {
    if (!_recording) return;
    _ticker?.cancel();
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {}
    final duration = _recordedElapsed;
    setState(() {
      _recording = false;
      _cancelArmed = false;
      _recordStart = null;
      _recordedElapsed = Duration.zero;
    });
    if (cancel || path == null) {
      if (path != null) await deleteFileIfExists(path);
      return;
    }
    if (duration.inMilliseconds < 600) {
      await deleteFileIfExists(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).chatVoiceHoldHint)),
        );
      }
      return;
    }
    widget.onSend(MessageComposerSendPayload(
      text: '',
      voicePath: path,
      voiceDurationMs: duration.inMilliseconds,
      replyToMessageId: widget.replyTo?.id,
    ));
  }

  // -------------- Send --------------
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingImagePaths.isEmpty) return;

    final editId = widget.editingMessageId;
    if (editId != null) {
      widget.onUpdate?.call(editId, text);
      return;
    }

    widget.onSend(MessageComposerSendPayload(
      text: text,
      imagePaths: _pendingImagePaths,
      replyToMessageId: widget.replyTo?.id,
    ));
    _controller.clear();
    setState(() => _pendingImagePaths = const []);
    _setTyping(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final isEditing = widget.editingMessageId != null;
    final reply = widget.replyTo;
    final hasContent =
        _controller.text.trim().isNotEmpty || _pendingImagePaths.isNotEmpty;

    final composer = Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing)
              _ComposerHeader(
                accentLabel: s.edit,
                preview: widget.editingInitialText ?? '',
                onCancel: _cancelEdit,
              )
            else if (reply != null)
              _ComposerHeader(
                accentLabel: s.chatReplyingTo(
                  reply.senderName.isNotEmpty ? reply.senderName : '…',
                ),
                preview: reply.text.isNotEmpty
                    ? reply.text
                    : (reply.hasImages
                        ? '[photo]'
                        : reply.hasVoice
                            ? '[voice]'
                            : ''),
                onCancel: widget.onCancelReply,
              ),
            if (_pendingImagePaths.isNotEmpty && !_recording)
              _AttachmentStrip(
                paths: _pendingImagePaths,
                onRemove: _removeImage,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isEditing && !_recording)
                    IconButton(
                      tooltip: s.chatAttach,
                      onPressed: widget.isDesktop ? _pickPhotos : _showAttachSheet,
                      icon: Icon(
                        LucideIcons.paperclip,
                        color: colors.textMuted,
                      ),
                    ),
                  Expanded(
                    child: _recording
                        ? _RecordingBar(
                            elapsed: _recordedElapsed,
                            cancelArmed: _cancelArmed,
                          )
                        : Shortcuts(
                            shortcuts: widget.isDesktop
                                ? <ShortcutActivator, Intent>{
                                    const SingleActivator(
                                      LogicalKeyboardKey.enter,
                                      shift: false,
                                    ): const _SendMessageIntent(),
                                  }
                                : const {},
                            child: Actions(
                              actions: widget.isDesktop
                                  ? <Type, Action<Intent>>{
                                      _SendMessageIntent:
                                          CallbackAction<_SendMessageIntent>(
                                        onInvoke: (_) {
                                          if (!widget.isSending &&
                                              (hasContent || isEditing)) {
                                            _submit();
                                          }
                                          return null;
                                        },
                                      ),
                                    }
                                  : const {},
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                minLines: 1,
                                maxLines: 5,
                                scrollPadding: EdgeInsets.zero,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: widget.isDesktop
                                    ? TextInputAction.newline
                                    : TextInputAction.send,
                                onEditingComplete: widget.isDesktop
                                    ? null
                                    : () {
                                        if (!widget.isSending) _submit();
                                      },
                                decoration: InputDecoration(
                                  hintText: widget.isDesktop
                                      ? (isEditing
                                          ? s.update
                                          : s.chatMessageHintDesktop)
                                      : (isEditing
                                          ? s.update
                                          : s.chatMessageHint),
                                  filled: true,
                                  fillColor: colors.surfaceMuted,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.rL,
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  _SendOrMic(
                    colors: colors,
                    isSending: widget.isSending,
                    isDesktop: widget.isDesktop,
                    showSend: hasContent || isEditing,
                    isEditing: isEditing,
                    onSend: _submit,
                    onMicDown: _startRecording,
                    onMicCancel: () => _finishRecording(cancel: true),
                    onMicSend: () => _finishRecording(cancel: false),
                    onMicSlide: (cancelArmed) {
                      if (_cancelArmed != cancelArmed) {
                        setState(() => _cancelArmed = cancelArmed);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

    final wrapped = widget.isDesktop
        ? Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ChatResponsive.messageColumnMaxWidth,
              ),
              child: composer,
            ),
          )
        : composer;

    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: mq.padding.left,
        right: mq.padding.right,
        bottom: mq.padding.bottom,
      ),
      child: wrapped,
    );
  }

  void _showAttachSheet() {
    final colors = context.appColors;
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.image, color: colors.textPrimary),
              title: Text(s.chatAttachPhotos),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhotos();
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.camera, color: colors.textPrimary),
              title: Text(s.chatTakePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerHeader extends StatelessWidget {
  const _ComposerHeader({
    required this.accentLabel,
    required this.preview,
    this.onCancel,
  });

  final String accentLabel;
  final String preview;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accentLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            IconButton(
              onPressed: onCancel,
              icon: Icon(LucideIcons.x, color: colors.textMuted),
              tooltip: S.of(context).cancel,
            ),
        ],
      ),
    );
  }
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({required this.paths, required this.onRemove});

  final List<String> paths;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        itemCount: paths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: localImage(
                paths[i],
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Material(
                shape: const CircleBorder(),
                color: colors.danger,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onRemove(i),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingBar extends StatefulWidget {
  const _RecordingBar({required this.elapsed, required this.cancelArmed});
  final Duration elapsed;
  final bool cancelArmed;

  @override
  State<_RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<_RecordingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.rL,
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: .35, end: 1.0).animate(_pulse),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.danger,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _fmt(widget.elapsed),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                widget.cancelArmed
                    ? s.chatVoiceReleaseToCancel
                    : s.chatVoiceSlideToCancel,
                key: ValueKey<bool>(widget.cancelArmed),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: widget.cancelArmed
                      ? colors.danger
                      : colors.textMuted,
                  fontWeight: widget.cancelArmed
                      ? FontWeight.w700
                      : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendMessageIntent extends Intent {
  const _SendMessageIntent();
}

class _SendOrMic extends StatefulWidget {
  const _SendOrMic({
    required this.colors,
    required this.isSending,
    required this.isDesktop,
    required this.showSend,
    required this.isEditing,
    required this.onSend,
    required this.onMicDown,
    required this.onMicCancel,
    required this.onMicSend,
    required this.onMicSlide,
  });

  final AppColors colors;
  final bool isSending;
  final bool isDesktop;
  final bool showSend;
  final bool isEditing;
  final VoidCallback onSend;
  final Future<void> Function() onMicDown;
  final VoidCallback onMicCancel;
  final VoidCallback onMicSend;
  final ValueChanged<bool> onMicSlide;

  @override
  State<_SendOrMic> createState() => _SendOrMicState();
}

class _SendOrMicState extends State<_SendOrMic> {
  bool _holding = false;
  double _accDx = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.showSend) {
      return Material(
        color: widget.colors.primary,
        borderRadius: AppRadius.rM,
        child: InkWell(
          onTap: widget.isSending ? null : widget.onSend,
          borderRadius: AppRadius.rM,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: widget.isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.colors.onPrimary,
                    ),
                  )
                : Icon(
                    widget.isEditing
                        ? LucideIcons.check
                        : LucideIcons.send,
                    color: widget.colors.onPrimary,
                    size: 20,
                  ),
          ),
        ),
      );
    }

    if (widget.isDesktop) {
      return Material(
        color: _holding ? widget.colors.danger : widget.colors.primary,
        borderRadius: AppRadius.rM,
        child: InkWell(
          onTap: _holding
              ? () {
                  setState(() => _holding = false);
                  widget.onMicSend();
                }
              : () async {
                  setState(() => _holding = true);
                  await widget.onMicDown();
                },
          borderRadius: AppRadius.rM,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              _holding ? LucideIcons.square : LucideIcons.mic,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) async {
        setState(() {
          _holding = true;
          _accDx = 0;
        });
        await widget.onMicDown();
      },
      onLongPressMoveUpdate: (d) {
        _accDx += d.offsetFromOrigin.dx;
        widget.onMicSlide(_accDx < -64);
      },
      onLongPressEnd: (_) {
        if (!_holding) return;
        setState(() => _holding = false);
        if (_accDx < -64) {
          widget.onMicCancel();
        } else {
          widget.onMicSend();
        }
        _accDx = 0;
      },
      onLongPressCancel: () {
        if (!_holding) return;
        setState(() => _holding = false);
        widget.onMicCancel();
        _accDx = 0;
      },
      child: AnimatedScale(
        scale: _holding ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Material(
          color: _holding ? widget.colors.danger : widget.colors.primary,
          borderRadius: AppRadius.rM,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(LucideIcons.mic,
                color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
