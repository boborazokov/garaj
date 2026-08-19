import 'dart:async';

/// Debounced signal emitted after WS reconnect (token refresh / network).
class WebSocketRecoveryEvent {
  const WebSocketRecoveryEvent({
    required this.reason,
    required this.at,
  });

  final String reason;
  final DateTime at;
}

/// Coordinates post-reconnect delta sync for chat and other subscriptions.
class WebSocketRecoveryService {
  WebSocketRecoveryService._();
  static final WebSocketRecoveryService instance = WebSocketRecoveryService._();

  static const _debounce = Duration(milliseconds: 500);

  final _events = StreamController<WebSocketRecoveryEvent>.broadcast();
  final List<void Function(WebSocketRecoveryEvent)> _listeners = [];

  Timer? _debounceTimer;
  String? _pendingReason;
  DateTime? _lastEmitted;

  Stream<WebSocketRecoveryEvent> get events => _events.stream;

  DateTime? get lastRecoveryAt => _lastEmitted;

  void register(void Function(WebSocketRecoveryEvent) listener) {
    _listeners.add(listener);
  }

  void unregister(void Function(WebSocketRecoveryEvent) listener) {
    _listeners.remove(listener);
  }

  /// Schedule recovery sync (debounced — multiple reconnect signals collapse).
  void scheduleRecovery({String reason = 'ws_reconnect'}) {
    _pendingReason = reason;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, _emitPending);
  }

  void _emitPending() {
    final reason = _pendingReason ?? 'ws_reconnect';
    _pendingReason = null;
    final event = WebSocketRecoveryEvent(reason: reason, at: DateTime.now());
    _lastEmitted = event.at;
    if (!_events.isClosed) {
      _events.add(event);
    }
    final copy = List<void Function(WebSocketRecoveryEvent)>.from(_listeners);
    for (final listener in copy) {
      listener(event);
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _events.close();
    _listeners.clear();
  }
}
