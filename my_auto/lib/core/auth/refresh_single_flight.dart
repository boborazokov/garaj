import 'dart:async';

/// Ensures only one async refresh runs; concurrent callers share the same result.
class RefreshSingleFlight {
  RefreshSingleFlight({this.timeout = const Duration(seconds: 30)});

  final Duration timeout;

  Completer<bool>? _inFlight;

  bool get isRunning => _inFlight != null;

  /// Awaits an in-flight refresh without starting a new one.
  Future<void> whenIdle() async {
    final flight = _inFlight;
    if (flight != null) await flight.future;
  }

  /// Runs [action] once; parallel callers await the same outcome.
  Future<bool> run(Future<bool> Function() action) async {
    final existing = _inFlight;
    if (existing != null) {
      return existing.future;
    }

    final completer = Completer<bool>();
    _inFlight = completer;

    try {
      final ok = await action().timeout(
        timeout,
        onTimeout: () => false,
      );
      if (!completer.isCompleted) completer.complete(ok);
      return ok;
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
      return false;
    } finally {
      if (identical(_inFlight, completer)) {
        _inFlight = null;
      }
    }
  }

  /// Clears in-flight state (e.g. forced logout during refresh).
  void reset() {
    _inFlight = null;
  }
}
