import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Compact voice message player used inside chat bubbles.
///
/// Renders the classic "play button + waveform + duration" layout
/// (Telegram / WhatsApp style). One `AudioPlayer` per widget instance
/// — playback is exclusive: starting one bubble pauses the previous
/// thanks to `AudioPlayers`' global audio context.
class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer({
    super.key,
    required this.source,
    required this.isMine,
    this.durationMs,
  });

  /// Either a remote URL (https://) or a local file path for the
  /// optimistic outbox case.
  final String source;
  final bool isMine;
  final int? durationMs;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late final AudioPlayer _player;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    if (widget.durationMs != null && widget.durationMs! > 0) {
      _total = Duration(milliseconds: widget.durationMs!);
    }
    _posSub = _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
    _durSub = _player.onDurationChanged.listen((dur) {
      if (!mounted) return;
      setState(() => _total = dur);
    });
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
      if (state == PlayerState.completed) {
        setState(() => _position = Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    try {
      final src = widget.source;
      if (src.startsWith('http')) {
        await _player.play(UrlSource(src));
      } else if (src.startsWith('/') ||
          src.startsWith('file://') ||
          (src.length > 2 && src[1] == ':')) {
        await _player.play(DeviceFileSource(src));
      } else {
        // Defensive fallback — treat unknown scheme as URL.
        await _player.play(UrlSource(src));
      }
    } catch (_) {
      // Swallow playback errors — bubble stays static.
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = widget.isMine ? colors.onPrimary : colors.textPrimary;
    final accent = widget.isMine
        ? colors.onPrimary
        : colors.primary;
    final track = widget.isMine
        ? colors.onPrimary.withValues(alpha: .25)
        : colors.primary.withValues(alpha: .25);

    final progress = _total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: 180,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: accent.withValues(alpha: widget.isMine ? .18 : .12),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  _playing ? LucideIcons.pause : LucideIcons.play,
                  size: 16,
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: track,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(_position.inMilliseconds == 0 ? _total : _position),
                  style: TextStyle(
                    color: fg.withValues(alpha: .8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
