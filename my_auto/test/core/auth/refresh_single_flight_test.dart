import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_auto/core/auth/refresh_single_flight.dart';

void main() {
  test('parallel callers share one refresh outcome', () async {
    final gate = RefreshSingleFlight();
    var calls = 0;

    Future<bool> refresh() async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return true;
    }

    final results = await Future.wait([
      gate.run(refresh),
      gate.run(refresh),
      gate.run(refresh),
      gate.run(refresh),
      gate.run(refresh),
    ]);

    expect(calls, 1);
    expect(results, everyElement(true));
  });

  test('failed refresh propagates false to waiters', () async {
    final gate = RefreshSingleFlight();
    var calls = 0;

    final results = await Future.wait([
      gate.run(() async {
        calls++;
        return false;
      }),
      gate.run(() async {
        calls++;
        return true;
      }),
    ]);

    expect(calls, 1);
    expect(results[0], false);
    expect(results[1], false);
  });

  test('whenIdle waits without starting new refresh', () async {
    final gate = RefreshSingleFlight();
    late Completer<void> blocker;

    final refreshFuture = gate.run(() async {
      blocker = Completer<void>();
      await blocker.future;
      return true;
    });

    final idleFuture = gate.whenIdle();
    expect(gate.isRunning, true);

    blocker.complete();
    await refreshFuture;
    await idleFuture;
    expect(gate.isRunning, false);
  });
}
