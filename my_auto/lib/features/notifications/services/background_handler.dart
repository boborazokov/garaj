import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_options_stub.dart';

/// Top-level entry point invoked by the FCM SDK when the app is in the
/// background OR terminated and a *data* message arrives.
///
/// CRITICAL constraints (per `firebase_messaging` docs):
///  * MUST be a top-level (or static) function, NOT a closure.
///  * MUST be annotated with `@pragma('vm:entry-point')` so AOT
///    builds don't tree-shake it away.
///  * MUST initialize Firebase explicitly — the isolate that runs this
///    handler is fresh and has no `Firebase.initializeApp()` cached.
///
/// We intentionally keep this handler minimal:
///  * No bloc / repository access — they live on the main isolate.
///  * The FCM SDK itself displays the *notification* portion of the
///    message; this handler is for *data-only* messages and for any
///    side-effects we want to run before the user taps.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await AppFirebase.initialize();

  if (kDebugMode) {
    // ignore: avoid_print
    print(
      '[bg-push] id=${message.messageId} '
      'type=${message.data['type']} '
      'deepLink=${message.data['deepLink']}',
    );
  }
  // No further work: the system tray UI is owned by FCM (notification
  // payload) and deep-link routing is done when the user taps and the
  // main isolate boots.
}
