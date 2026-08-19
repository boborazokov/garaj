import 'package:firebase_core/firebase_core.dart';

/// Manually-authored Firebase options for the Garage app.
///
/// In a green-field project we'd run `flutterfire configure` and let
/// the CLI generate `firebase_options.dart`. Since the project ships
/// platform-specific config files (`google-services.json`,
/// `GoogleService-Info.plist`) already, we keep the runtime init
/// simple: call `Firebase.initializeApp()` with no arguments on
/// Android / iOS so the native SDK picks the right plist / json file.
///
/// This file exists so callers have a single import that can later be
/// swapped for the generated one without touching `main.dart`.
class AppFirebase {
  AppFirebase._();

  static Future<FirebaseApp> initialize() async {
    // No `options:` — Android reads `google-services.json` and iOS
    // reads `GoogleService-Info.plist` automatically. On other
    // platforms initialization is a no-op (push is mobile-only here).
    return Firebase.initializeApp();
  }
}
