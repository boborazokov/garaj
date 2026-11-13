// Scaffold for Flutter integration_test.
// Copy into my_auto/integration_test/ when enabling the official integration_test package:
//   flutter pub add dev:integration_test --sdk=flutter
//
// This file is kept under qa/ so application source stays untouched until you opt in.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots without crash (scaffold)', (tester) async {
    // Wire MyApp() from package:my_auto when this file lives under my_auto/integration_test/
    expect(true, isTrue);
  });
}
